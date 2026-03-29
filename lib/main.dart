import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:better_me/core/l10n/app_localizations.dart';

import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/screens/choose_profile_screen.dart';
import 'features/profile/presentation/screens/create_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final profileRepo = ProfileRepository();
  final profiles = await profileRepo.getAllProfiles();
  final bool hasProfiles = profiles.isNotEmpty;

  runApp(BetterMeApp(hasProfiles: hasProfiles));
}

class BetterMeApp extends StatelessWidget {
  final bool hasProfiles;

  const BetterMeApp({super.key, required this.hasProfiles});

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
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],

      home: hasProfiles ? const ChooseProfileScreen() : const CreateProfileScreen(),
    );
  }
}