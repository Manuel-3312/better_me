import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for persistence
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:better_me/features/profile/presentation/screens/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Load the saved theme preference before the app runs
  final prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('theme_mode');

  // Convert the saved string back to ThemeMode, default to Dark if null
  ThemeMode initialTheme;
  if (savedTheme == 'light') {
    initialTheme = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    initialTheme = ThemeMode.dark;
  } else {
    initialTheme = ThemeMode.dark; // Default to Dark Mode as requested
  }

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(BetterMeApp(initialTheme: initialTheme));
}

/// The root widget of the application with theme persistence.
class BetterMeApp extends StatefulWidget {
  final ThemeMode initialTheme;

  const BetterMeApp({super.key, required this.initialTheme});

  static void setLocale(BuildContext context, Locale newLocale) {
    _BetterMeAppState? state = context
        .findAncestorStateOfType<_BetterMeAppState>();
    state?.setLocale(newLocale);
  }

  static void setTheme(BuildContext context, ThemeMode newTheme) {
    _BetterMeAppState? state = context
        .findAncestorStateOfType<_BetterMeAppState>();
    state?.setTheme(newTheme);
  }

  static ThemeMode getTheme(BuildContext context) {
    _BetterMeAppState? state = context
        .findAncestorStateOfType<_BetterMeAppState>();
    return state?._themeMode ?? ThemeMode.dark;
  }

  @override
  State<BetterMeApp> createState() => _BetterMeAppState();
}

class _BetterMeAppState extends State<BetterMeApp> {
  late ThemeMode _themeMode;
  Locale _locale = const Locale('es');

  @override
  void initState() {
    super.initState();
    // Initialize with the value loaded in main()
    _themeMode = widget.initialTheme;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  /// Updates the theme mode and saves the choice to SharedPreferences.
  void setTheme(ThemeMode themeMode) async {
    setState(() {
      _themeMode = themeMode;
    });

    // Persist the choice
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      themeMode.name,
    ); // Saves 'light' or 'dark'
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterMe',
      debugShowCheckedModeBanner: false,
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
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: const AnimatedSplashScreen(),
    );
  }
}
