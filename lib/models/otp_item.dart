import 'package:otp/otp.dart';

/// The kind of one-time password. TOTP is time-based (auto-refreshing); HOTP is
/// counter-based (advances only when the user requests the next code).
enum OtpType { totp, hotp }

class OtpItem {
  final String label;
  final String secret;
  final String issuer;
  final int length;
  final int interval;
  final Algorithm algorithm;
  final OtpType type;

  /// HOTP counter. Ignored for TOTP. Persisted inside the otpauth URI so the
  /// on-disk/backup/cloud format stays a plain list of otpauth URI strings.
  final int counter;

  OtpItem({
    required this.label,
    required this.secret,
    required this.issuer,
    this.length = 6,
    this.interval = 30,
    this.algorithm = Algorithm.SHA1,
    this.type = OtpType.totp,
    this.counter = 0,
  });

  factory OtpItem.fromUri(String uri) {
    final parsedUri = Uri.parse(uri);
    if (parsedUri.scheme != 'otpauth') {
      throw FormatException('Invalid OTP URI scheme: ${parsedUri.scheme}');
    }

    final host = parsedUri.host.toLowerCase();
    if (host != 'totp' && host != 'hotp') {
      throw FormatException('Invalid OTP URI type: ${parsedUri.host}');
    }

    final String label = Uri.decodeComponent(parsedUri.path.substring(1));
    final secret = parsedUri.queryParameters['secret'] ?? '';
    if (!_isValidBase32Secret(secret)) {
      throw const FormatException('Invalid OTP secret.');
    }

    final length = _parsePositiveInt(
      parsedUri.queryParameters['digits'],
      defaultValue: 6,
      fieldName: 'digits',
    );
    final interval = _parsePositiveInt(
      parsedUri.queryParameters['period'],
      defaultValue: 30,
      fieldName: 'period',
    );
    final algorithm = _parseAlgorithm(parsedUri.queryParameters['algorithm']);
    final type = host == 'hotp' ? OtpType.hotp : OtpType.totp;
    final counter = type == OtpType.hotp
        ? _parseRequiredNonNegativeInt(
            parsedUri.queryParameters['counter'],
            fieldName: 'counter',
          )
        : 0;
    final issuer = parsedUri.queryParameters['issuer'] ?? '';

    return OtpItem(
      label: label,
      secret: secret,
      issuer: issuer,
      length: length,
      interval: interval,
      algorithm: algorithm,
      type: type,
      counter: counter,
    );
  }

  static bool isValidUri(String uri) {
    try {
      OtpItem.fromUri(uri);
      return true;
    } catch (_) {
      return false;
    }
  }

  OtpItem copyWith({int? counter}) {
    return OtpItem(
      label: label,
      secret: secret,
      issuer: issuer,
      length: length,
      interval: interval,
      algorithm: algorithm,
      type: type,
      counter: counter ?? this.counter,
    );
  }

  /// Serializes back to an otpauth URI. Round-trips with [fromUri]. The HOTP
  /// `counter` is only emitted for HOTP entries so existing TOTP URIs are
  /// reproduced unchanged.
  String toUri() {
    final uri = Uri(
      scheme: 'otpauth',
      host: type == OtpType.hotp ? 'hotp' : 'totp',
      path: label,
      queryParameters: {
        'secret': secret,
        if (issuer.isNotEmpty) 'issuer': issuer,
        if (length != 6) 'digits': '$length',
        if (interval != 30) 'period': '$interval',
        if (algorithm != Algorithm.SHA1)
          'algorithm': algorithm.toString().split('.').last,
        if (type == OtpType.hotp) 'counter': '$counter',
      },
    );
    return uri.toString();
  }

  /// A stable key for the *account* — every field except the HOTP counter.
  /// Two entries with the same [identityKey] are the same account (e.g. the
  /// same HOTP secret at different counters), which is what merge/sync dedupes
  /// on. Derived, never stored, so it can't affect the on-disk format.
  String get identityKey => copyWith(counter: 0).toUri();

  /// Generates the current OTP code. Pure (no `BuildContext`), so it is unit
  /// testable against RFC 6238 / RFC 4226 vectors. [atMillis] overrides the
  /// clock for TOTP (used in tests); ignored for HOTP.
  String generate({int? atMillis}) {
    final upperSecret = secret.toUpperCase();
    if (type == OtpType.hotp) {
      return OTP.generateHOTPCodeString(
        upperSecret,
        counter,
        length: length,
        algorithm: algorithm,
        isGoogle: true,
      );
    }
    return OTP.generateTOTPCodeString(
      upperSecret,
      atMillis ?? DateTime.now().millisecondsSinceEpoch,
      length: length,
      interval: interval,
      algorithm: algorithm,
      isGoogle: true,
    );
  }

  static Algorithm _parseAlgorithm(String? algorithmStr) {
    switch (algorithmStr?.toUpperCase()) {
      case 'SHA256':
        return Algorithm.SHA256;
      case 'SHA512':
        return Algorithm.SHA512;
      default:
        return Algorithm.SHA1;
    }
  }

  static int _parsePositiveInt(
    String? value, {
    required int defaultValue,
    required String fieldName,
  }) {
    if (value == null) return defaultValue;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      throw FormatException('$fieldName must be a positive integer.');
    }
    return parsed;
  }

  static int _parseRequiredNonNegativeInt(
    String? value, {
    required String fieldName,
  }) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0) {
      throw FormatException('$fieldName must be a non-negative integer.');
    }
    return parsed;
  }

  static bool _isValidBase32Secret(String secret) {
    return RegExp(r'^[A-Za-z2-7]+={0,6}$').hasMatch(secret);
  }
}
