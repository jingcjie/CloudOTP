import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_otp/models/otp_item.dart';

enum AccountAuthMode { login, signup }

class AccountLinkResult {
  AccountLinkResult({
    required this.remoteData,
    required this.mergeRequired,
  });

  final List<String> remoteData;
  final bool mergeRequired;
}

class AccountLinkController extends ChangeNotifier {
  AccountLinkController({
    required SupabaseClient supabaseClient,
    required SharedPreferencesAsync preferences,
  })  : _supabase = supabaseClient,
        _prefs = preferences;

  final SupabaseClient _supabase;
  final SharedPreferencesAsync _prefs;

  static const _otpStorageKey = 'otpUris';
  static const _emailStorageKey = 'linkedEmail';
  static const _passwordStorageKey = 'linkedPassword';
  static const _schemaVersionKey = 'dataSchemaVersion';

  /// Current on-disk data-format version. Bump this and add a step to
  /// [_migrateStoredData] whenever the stored representation changes.
  static const _currentSchemaVersion = 1;

  bool _isLinked = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _linkedEmail;
  List<String> _otpUris = [];

  bool get isLinked => _isLinked;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get linkedEmail => _linkedEmail;
  UnmodifiableListView<String> get otpUris => UnmodifiableListView(_otpUris);
  List<String> get rawOtpUris => List<String>.from(_otpUris);

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final storedUris =
          await _prefs.getStringList(_otpStorageKey) ?? <String>[];
      _otpUris = List<String>.from(storedUris);

      await _migrateStoredData();

      final savedEmail = await _prefs.getString(_emailStorageKey);
      final savedPassword = await _prefs.getString(_passwordStorageKey);
      if (savedEmail != null && savedPassword != null) {
        try {
          await signIn(
              email: savedEmail, password: savedPassword, silent: true);
        } catch (error) {
          if (kDebugMode) {
            debugPrint('Auto link failed: $error');
          }
          await _clearStoredCredentials();
        }
      }
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<AccountLinkResult> authenticate({
    required AccountAuthMode mode,
    required String email,
    required String password,
  }) async {
    switch (mode) {
      case AccountAuthMode.login:
        return signIn(email: email, password: password);
      case AccountAuthMode.signup:
        await signUp(email: email, password: password);
        return AccountLinkResult(remoteData: const [], mergeRequired: false);
    }
  }

  Future<AccountLinkResult> signIn({
    required String email,
    required String password,
    bool silent = false,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id ?? _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw StateError('Missing user information after sign in.');
      }

      final remoteData = await _fetchRemoteData();
      await _ensureUserDataRow(userId);

      _linkedEmail = email;
      _isLinked = true;
      await _storeCredentials(email: email, password: password);

      await _persistLocal();

      if (!silent) {
        notifyListeners();
      }

      final requiresMerge =
          remoteData.isNotEmpty && !listEquals(remoteData, _otpUris);
      return AccountLinkResult(
          remoteData: remoteData, mergeRequired: requiresMerge);
    } catch (error) {
      if (!silent) {
        rethrow;
      }
      return AccountLinkResult(remoteData: const [], mergeRequired: false);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final userId = response.user?.id ?? _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _ensureUserDataRow(userId);
      }
      _linkedEmail = email;
      _isLinked = true;
      await _storeCredentials(email: email, password: password);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unlinkAccount() async {
    await _supabase.auth.signOut();
    _isLinked = false;
    _linkedEmail = null;
    await _clearStoredCredentials();
    notifyListeners();
  }

  Future<void> addOtp(String uri) async {
    _otpUris = [..._otpUris, uri];
    await _persistLocal();
    notifyListeners();
  }

  Future<void> removeOtpAt(int index) async {
    if (index < 0 || index >= _otpUris.length) return;
    _otpUris = List<String>.from(_otpUris)..removeAt(index);
    await _persistLocal();
    notifyListeners();
  }

  /// Replaces the URI at [index] in place and persists locally only. Cloud
  /// backup/download stays user-driven through the Settings actions, even when
  /// an account is linked.
  Future<void> updateOtpAt(int index, String uri) async {
    if (index < 0 || index >= _otpUris.length) return;
    if (_otpUris[index] == uri) return;
    _otpUris = List<String>.from(_otpUris)..[index] = uri;
    await _persistLocal();
    notifyListeners();
  }

  /// Merges [data] into the local list. Dedupes by account [OtpItem.identityKey]
  /// (not exact string), so an HOTP entry that differs only by counter is not
  /// duplicated — the higher counter wins. Stored strings are preserved verbatim
  /// (never re-serialized), and any URI that fails to parse falls back to
  /// exact-string dedupe so nothing is dropped or rewritten.
  Future<void> mergeWith(List<String> data) async {
    final result = List<String>.from(_otpUris);
    final identityToIndex = <String, int>{};
    for (var i = 0; i < result.length; i++) {
      final id = _identityOf(result[i]);
      if (id != null) {
        identityToIndex[id] = i;
      }
    }

    bool changed = false;
    for (final uri in data) {
      final id = _identityOf(uri);
      if (id == null) {
        // Unparseable: keep the exact-string behavior so we never lose it.
        if (!result.contains(uri)) {
          result.add(uri);
          changed = true;
        }
        continue;
      }
      final existingIndex = identityToIndex[id];
      if (existingIndex == null) {
        result.add(uri);
        identityToIndex[id] = result.length - 1;
        changed = true;
      } else if (_counterOf(uri) > _counterOf(result[existingIndex])) {
        // Same account, higher HOTP counter — adopt the incoming string as-is.
        result[existingIndex] = uri;
        changed = true;
      }
    }

    if (!changed) return;
    _otpUris = result;
    await _persistLocal();
    notifyListeners();
  }

  String? _identityOf(String uri) {
    try {
      return OtpItem.fromUri(uri).identityKey;
    } catch (_) {
      return null;
    }
  }

  int _counterOf(String uri) {
    try {
      return OtpItem.fromUri(uri).counter;
    } catch (_) {
      return 0;
    }
  }

  Future<void> replaceLocalWith(List<String> remoteData) async {
    await _replaceLocalData(remoteData);
    notifyListeners();
  }

  Future<List<String>> pullFromCloud() async {
    _ensureLinked();
    final remoteData = await _fetchRemoteData();
    await _replaceLocalData(remoteData);
    notifyListeners();
    return remoteData;
  }

  Future<void> pushToCloud() async {
    _ensureLinked();
    await _syncLocalToCloud();
  }

  Future<void> clearCloudData() async {
    _ensureLinked();
    await _supabase.from('user_data').update({'user_data': []}).eq(
        'user_id', _supabase.auth.currentUser!.id);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    if (_isInitialized) {
      notifyListeners();
    }
  }

  Future<void> _persistLocal() {
    return _prefs.setStringList(_otpStorageKey, _otpUris);
  }

  /// Runs any pending on-disk data migrations and stamps the current version.
  ///
  /// Installs that predate versioning have no stored version; they are already
  /// in the v1 format (a plain list of otpauth URIs), so they are treated as v1
  /// and migrated forward from there. This step does NOT touch [_otpUris] today
  /// — it only establishes the upgrade path. To evolve the format later: bump
  /// [_currentSchemaVersion] and add a `case n:` that transforms v(n) -> v(n+1),
  /// writing the result back via [_persistLocal].
  ///
  /// NOTE for future format changes: this runs once at startup on the *locally
  /// stored* list. Data ingested later from the cloud ([pullFromCloud], [signIn],
  /// [replaceLocalWith]) bypasses this path, so a real migration must also be
  /// applied to remote-sourced data (e.g. factor the transform into a pure
  /// function and call it from [_replaceLocalData]).
  Future<void> _migrateStoredData() async {
    var version = await _prefs.getInt(_schemaVersionKey) ?? 1;
    while (version < _currentSchemaVersion) {
      switch (version) {
        // case 1: await _migrateV1toV2(); break;
        default:
          break;
      }
      version++;
    }
    await _prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
  }

  Future<void> _replaceLocalData(List<String> data) async {
    _otpUris = List<String>.from(data);
    await _persistLocal();
  }

  Future<void> _storeCredentials({
    required String email,
    required String password,
  }) async {
    await _prefs.setString(_emailStorageKey, email);
    await _prefs.setString(_passwordStorageKey, password);
  }

  Future<void> _clearStoredCredentials() async {
    await _prefs.remove(_emailStorageKey);
    await _prefs.remove(_passwordStorageKey);
  }

  Future<void> _ensureUserDataRow(String userId) async {
    final existing = await _supabase.from('user_data').select().maybeSingle();
    if (existing == null) {
      await _supabase.from('user_data').insert({
        'user_id': userId,
        'user_data': [],
      });
    } else if (existing['user_data'] == null) {
      await _supabase
          .from('user_data')
          .update({'user_data': []}).eq('user_id', userId);
    }
  }

  Future<List<String>> _fetchRemoteData() async {
    final response = await _supabase.from('user_data').select().maybeSingle();
    if (response == null) {
      return <String>[];
    }
    final rawData = response['user_data'];
    if (rawData is List) {
      return rawData.cast<String>();
    }
    return <String>[];
  }

  Future<void> _syncLocalToCloud() async {
    await _supabase.from('user_data').update({'user_data': _otpUris}).eq(
        'user_id', _supabase.auth.currentUser!.id);
  }

  void _ensureLinked() {
    if (!_isLinked || _supabase.auth.currentUser == null) {
      throw StateError('Cloud account is not linked.');
    }
  }
}
