// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get createProfileTitle => 'Add your data';

  @override
  String get fullName => 'Full name';

  @override
  String get sex => 'Sex';

  @override
  String get weight => 'Weight (Kg)';

  @override
  String get height => 'Height (cm)';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get createButton => 'Create';

  @override
  String get chooseProfileTitle => 'Choose your profile';

  @override
  String get createProfileButton => 'Crearte profile';

  @override
  String get noProfilesMessage =>
      'There are no profiles yet. Create the first one!';

  @override
  String profileSelected(String profileName) {
    return 'You selected $profileName';
  }

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get requiredField => 'Required field';

  @override
  String get profileCreatedSuccess => 'Profile created successfully!';

  @override
  String get selectDateWarning => 'Please select your birth date';
}
