import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_otp/l10n/app_localizations.dart';
import 'utils/constants.dart';
import 'controllers/account_link_controller.dart';
import 'pages/main_page.dart';
import 'models/theme_provider.dart';
import 'models/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bclaahfvyffqzoqwwegd.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjbGFhaGZ2eWZmcXpvcXd3ZWdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ5MTcyMjcsImV4cCI6MjA0MDQ5MzIyN30.wAmbOCF70IcnqVylOUq9FqSzv3_pXcc7uEgVi7_qTQk',
  );

  // Keep the Supabase free-tier project from pausing after 7 days of inactivity:
  // fire a lightweight, unconditional keep-alive ping on every launch (linked or
  // not). Fire-and-forget — never blocks startup, never throws if offline/paused.
  _pingKeepAlive();

  final accountController = AccountLinkController(
    supabaseClient: Supabase.instance.client,
    preferences: prefs,
  );
  await accountController.initialize();
  if (!kIsWeb){
    if(kIsWIN||kIsMAC||kIsLIN){
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

        // Restore window size and position from SharedPreferences
        double width =  await prefs.getDouble('window_width') ?? 360.0;
        double height = await prefs.getDouble('window_height') ?? 720.0;
        await windowManager.setSize(Size(width, height));

        double? x =  await prefs.getDouble('window_x') ?? 10.0;
        double? y = await prefs.getDouble('window_y') ?? 10.0;
        await windowManager.setPosition(Offset(x, y));

        await windowManager.setMinimumSize(const Size(360, 360));
        await windowManager.show();
        await windowManager.setSkipTaskbar(false);
      });
      windowManager.addListener(MyWindowListener());
    }

  }

  runApp(MyApp(accountController: accountController));
}

/// Resets the Supabase free-tier 7-day inactivity timer so the project is never
/// auto-paused. Calls the `keep_alive()` RPC (granted to `anon`), which just
/// returns `now()`. Silent and non-blocking: a short timeout keeps a slow/paused
/// backend from leaving a dangling future, and all errors are swallowed.
void _pingKeepAlive() {
  unawaited(
    supabase
        .rpc('keep_alive')
        .timeout(const Duration(seconds: 10))
        .then(
          (_) {},
          onError: (Object e) => debugPrint('keep_alive ping failed (ignored): $e'),
        ),
  );
}

class MyWindowListener extends WindowListener {


  @override
  void onWindowResized() async {
    // This method is called when the window is resized
    await windowManager.ensureInitialized();
    Size? size = await windowManager.getSize();
    // Save size
    await prefs.setDouble('window_width', size.width);
    await prefs.setDouble('window_height', size.height);
    }

  @override
  void onWindowMoved() async {
    // This method is called when the window is moved
    await windowManager.ensureInitialized();
    Offset? position = await windowManager.getPosition();
    // Save position
    await prefs.setDouble('window_x', position.dx);
    await prefs.setDouble('window_y', position.dy);
    }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.accountController});

  final AccountLinkController accountController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider.value(value: widget.accountController),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              final forcedLocale = localeProvider.locale;
              if (forcedLocale != null) {
                return forcedLocale;
              }
              if (locale == null) {
                return const Locale('en');
              }
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale('en');
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.dark,
              ),
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!kIsWeb && (kIsWIN || kIsMAC || kIsLIN))
            Stack(
              children: [
                GestureDetector(
                  onPanStart: (details) {
                    windowManager.startDragging();
                  },
                  child: Container(
                    height: 32,
                    color: Colors.transparent,
                    child: Center(
                      child: Icon(
                        Icons.drag_handle,
                        size: 24,
                        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app_rounded),
                    onPressed: () {
                      exit(0);
                    },
                  ),
                ),
              ],
            ),
          const Expanded(
            child: MainPage(),
          ),
        ],
      ),
    );
  }
}
