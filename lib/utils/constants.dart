import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
// System env

final bool kIsAnd = Platform.isAndroid;
final bool kIsIOS = Platform.isIOS;
final bool kIsWIN = Platform.isWindows;
final bool kIsLIN = Platform.isLinux;
final bool kIsMAC = Platform.isMacOS;

// Global variables
final supabase = Supabase.instance.client;
final SharedPreferencesAsync prefs = SharedPreferencesAsync();


// bool isValidOtpUri(String uri) {
//   // Basic validation for OTP URI format
//   RegExp otpUriRegex = RegExp(r'^otpauth:\/\/(totp|hotp)\/(.+)\?secret=([A-Z2-7]+)(&.+)?$');
//   return otpUriRegex.hasMatch(uri);
// }
bool isValidOtpUri(String uriString) {
  try {
    final uri = Uri.parse(uriString);

    // Check if the scheme is 'otpauth'
    if (uri.scheme != 'otpauth') {
      return false;
    }

    // Check if the host is either 'totp' or 'hotp'
    if (uri.host != 'totp' && uri.host != 'hotp') {
      return false;
    }

    // Extract and check the secret and issuer
    final secret = uri.queryParameters['secret'] ?? '';

    // Check if secret is present and non-empty
    if (secret.isEmpty) {
      return false;
    }

    // Optional: You can add more specific checks here if needed
    // For example, checking if the secret is valid base32:
    // if (!RegExp(r'^[A-Z2-7]+$').hasMatch(secret)) {
    //   return false;
    // }

    // If we've passed all checks, consider it valid
    return true;
  } catch (e) {
    // If URI parsing fails, consider it invalid
    return false;
  }
}

