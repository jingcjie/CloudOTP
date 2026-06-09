import 'package:cloud_otp/models/otp_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
// System env

final bool kIsAnd = Platform.isAndroid;
final bool kIsIOS = Platform.isIOS;
final bool kIsWIN = Platform.isWindows;
final bool kIsLIN = Platform.isLinux;
final bool kIsMAC = Platform.isMacOS;

// Global variables
final supabase = Supabase.instance.client;
final SharedPreferencesAsync prefs = SharedPreferencesAsync();

bool isValidOtpUri(String uriString) {
  return OtpItem.isValidUri(uriString);
}
