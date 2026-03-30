import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'features/profile/presentation/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop initialization for SQLite
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const BetterMeApp());
}

/// The root widget of the application.
/// It manages the global state for the application's locale (language).
class BetterMeApp extends StatefulWidget {
  const BetterMeApp({super.key});

  /// Allows descendant widgets to update the application's locale.
  /// This is a common and efficient pattern in Flutter for global state toggles.
  static void setLocale(BuildContext context, Locale newLocale) {
    _BetterMeAppState? state = context.findAncestorStateOfType<_BetterMeAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<BetterMeApp> createState() => _BetterMeAppState();
}

class _BetterMeAppState extends State<BetterMeApp> {
  // Default locale is Spanish
  Locale _locale = const Locale('es');

  /// Updates the internal locale state and triggers a full app rebuild
  /// to reflect the new language strings.
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterMe',
      debugShowCheckedModeBanner: false,
      locale: _locale, // Bind the current locale state to the app
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
      // The app always boots directly to the Welcome Screen
      home: const WelcomeScreen(),
    );
  }
}