import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/profile/presentation/screens/welcome_screen.dart';
import 'features/profile/presentation/screens/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Desktop initialization for SQLite (Windows/Linux)
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const BetterMeApp());
}

/// The root widget of the application.
/// Manages global state for localization and theme mode (Light/Dark).
class BetterMeApp extends StatefulWidget {
  const BetterMeApp({super.key});

  /// Updates the application's locale from any descendant widget.
  static void setLocale(BuildContext context, Locale newLocale) {
    _BetterMeAppState? state = context.findAncestorStateOfType<_BetterMeAppState>();
    state?.setLocale(newLocale);
  }

  /// Updates the application's theme mode globally.
  static void setTheme(BuildContext context, ThemeMode newTheme) {
    _BetterMeAppState? state = context.findAncestorStateOfType<_BetterMeAppState>();
    state?.setTheme(newTheme);
  }

  /// Returns the current theme mode to help UI elements react to changes.
  static ThemeMode getTheme(BuildContext context) {
    _BetterMeAppState? state = context.findAncestorStateOfType<_BetterMeAppState>();
    return state?._themeMode ?? ThemeMode.light;
  }

  @override
  State<BetterMeApp> createState() => _BetterMeAppState();
}

class _BetterMeAppState extends State<BetterMeApp> {
  // Default states: Spanish locale and Light theme.
  Locale _locale = const Locale('es');
  ThemeMode _themeMode = ThemeMode.light;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterMe',
      debugShowCheckedModeBanner: false,

      // Theme & Localization Configuration
      locale: _locale,
      themeMode: _themeMode,

      // Light Theme Definition
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // Dark Theme Definition
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep grey for Dark Mode
      ),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],

      // THE ENTRY POINT: Now starts with the sequential animation sequence.
      home: const AnimatedSplashScreen(),
    );
  }
}