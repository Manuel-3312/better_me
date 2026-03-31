import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:better_me/features/profile/presentation/screens/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('theme_mode');

  ThemeMode initialTheme;
  if (savedTheme == 'light') {
    initialTheme = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    initialTheme = ThemeMode.dark;
  } else {
    initialTheme = ThemeMode.dark;
  }

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(BetterMeApp(initialTheme: initialTheme));
}

class BetterMeApp extends StatefulWidget {
  final ThemeMode initialTheme;

  const BetterMeApp({super.key, required this.initialTheme});

  /// Provides access to the app state for theme and locale changes.
  /// Helper method to find the state within the widget tree.
  static _BetterMeAppState of(BuildContext context) {
    final _BetterMeAppState? result =
    context.findAncestorStateOfType<_BetterMeAppState>();
    if (result != null) return result;
    throw Exception('BetterMeApp state not found in context');
  }

  static void setLocale(BuildContext context, Locale newLocale) {
    of(context).setLocale(newLocale);
  }

  static void setTheme(BuildContext context, ThemeMode newTheme) {
    of(context).setTheme(newTheme);
  }

  static ThemeMode getTheme(BuildContext context) {
    return of(context)._themeMode;
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
    _themeMode = widget.initialTheme;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setTheme(ThemeMode themeMode) async {
    setState(() {
      _themeMode = themeMode;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', themeMode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterMe',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
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