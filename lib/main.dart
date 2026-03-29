import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/profile/presentation/screens/create_profile_screen.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

void main() {
  runApp(const BetterMeApp());
}

class BetterMeApp extends StatelessWidget {
  const BetterMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetterMe',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('es'), Locale('en')],

      home: const CreateProfileScreen(),
    );
  }
}
