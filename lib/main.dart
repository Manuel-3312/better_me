import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/features/profile/presentation/screens/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final results = await Future.wait([
    dotenv.load(fileName: ".env"),
    SharedPreferences.getInstance(),
  ]);

  final prefs = results[1] as SharedPreferences;

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final String? savedTheme = prefs.getString('theme_mode');
  final String? savedLocale = prefs.getString('selected_locale');

  runApp(BetterMeApp(
    initialTheme: _parseTheme(savedTheme),
    initialLocale: savedLocale ?? 'es',
  ));
}

ThemeMode _parseTheme(String? themeStr) {
  switch (themeStr) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.dark;
  }
}

class BetterMeApp extends StatefulWidget {
  final ThemeMode initialTheme;
  final String initialLocale;

  const BetterMeApp({
    super.key,
    required this.initialTheme,
    required this.initialLocale,
  });

  static _BetterMeAppState of(BuildContext context) {
    final _BetterMeAppState? result =
    context.findAncestorStateOfType<_BetterMeAppState>();
    if (result != null) return result;
    throw Exception('BetterMeApp state not found in context');
  }

  static void setLocale(BuildContext context, Locale newLocale) =>
      of(context).changeLocale(newLocale);

  static void setTheme(BuildContext context, ThemeMode newTheme) =>
      of(context).changeTheme(newTheme);

  @override
  State<BetterMeApp> createState() => _BetterMeAppState();
}

class _BetterMeAppState extends State<BetterMeApp> {
  late ThemeMode _themeMode;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
    _locale = Locale(widget.initialLocale);
  }

  void changeLocale(Locale locale) async {
    if (_locale == locale) return;
    setState(() => _locale = locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale.languageCode);
  }

  void changeTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    setState(() => _themeMode = themeMode);
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

      theme: _AppTheme.light,
      darkTheme: _AppTheme.dark,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AnimatedSplashScreen(),
    );
  }
}

abstract class _AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.green,
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.green,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );
}