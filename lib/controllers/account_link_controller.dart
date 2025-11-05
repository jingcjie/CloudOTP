import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
      final storedUris = await _prefs.getStringList(_otpStorageKey) ?? <String>[];
      _otpUris = List<String>.from(storedUris);

      final savedEmail = await _prefs.getString(_emailStorageKey);
      final savedPassword = await _prefs.getString(_passwordStorageKey);
      if (savedEmail != null && savedPassword != null) {
        try {
          await signIn(email: savedEmail, password: savedPassword, silent: true);
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

      if (_otpUris.isEmpty && remoteData.isNotEmpty) {
        await _replaceLocalData(remoteData);
      } else {
        await _persistLocal();
      }

      if (!silent) {
        notifyListeners();
      }

      final requiresMerge = remoteData.isNotEmpty && _otpUris.isNotEmpty;
      return AccountLinkResult(remoteData: remoteData, mergeRequired: requiresMerge);
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
      await _syncLocalToCloud();
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

  Future<void> mergeWith(List<String> data) async {
    bool changed = false;
    final updated = List<String>.from(_otpUris);
    for (final uri in data) {
      if (!updated.contains(uri)) {
        updated.add(uri);
        changed = true;
      }
    }
    if (!changed) return;
    _otpUris = updated;
    await _persistLocal();
    notifyListeners();
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
    await _supabase
        .from('user_data')
        .update({'user_data': []}).eq('user_id', _supabase.auth.currentUser!.id);
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
    await _supabase
        .from('user_data')
        .update({'user_data': _otpUris}).eq('user_id', _supabase.auth.currentUser!.id);
  }

  void _ensureLinked() {
    if (!_isLinked || _supabase.auth.currentUser == null) {
      throw StateError('Cloud account is not linked.');
    }
  }
}
