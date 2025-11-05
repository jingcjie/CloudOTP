import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  static const _localeStorageKey = 'appLocale';

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('zh'),
  ];

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final stored = await prefs.getString(_localeStorageKey);
    if (stored == null || stored.isEmpty || stored == 'system') {
      _locale = null;
    } else {
      final segments = stored.split('_');
      _locale = segments.length > 1
          ? Locale(segments.first, segments[1])
          : Locale(segments.first);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();

    if (locale == null) {
      await prefs.setString(_localeStorageKey, 'system');
      return;
    }

    final value = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await prefs.setString(_localeStorageKey, value);
  }
}
