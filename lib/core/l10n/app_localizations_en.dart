// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get headerWelcome => '--- WELCOME SCREEN ---';

  @override
  String get welcomeTitle => 'Welcome to BetterMe';

  @override
  String get swipeToStart => 'Swipe up to start';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get headerProfile => '--- PROFILE MANAGEMENT ---';

  @override
  String get createProfileTitle => 'Add your data';

  @override
  String get editProfileTitle => 'Edit profile';

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
  String get updateButton => 'Update';

  @override
  String get profileCreatedSuccess => 'Profile created successfully!';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get requiredField => 'Required field';

  @override
  String get selectDateWarning => 'Please select your birth date';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get headerSelection => '--- PROFILE SELECTION ---';

  @override
  String get chooseProfileTitle => 'Choose your profile';

  @override
  String get createProfileButton => 'Create profile';

  @override
  String get noProfilesMessage =>
      'There are no profiles yet. Create the first one!';

  @override
  String profileSelected(String profileName) {
    return 'You selected $profileName';
  }

  @override
  String get deleteProfileTitle => 'Delete profile';

  @override
  String deleteProfileContent(String profileName) {
    return 'Are you sure you want to delete $profileName?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get profileDeleted => 'Profile deleted';

  @override
  String get undo => 'Undo';

  @override
  String get headerDashboard => '--- DASHBOARD ---';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String welcomeUser(String name) {
    return 'Hello, $name!';
  }

  @override
  String ageLabel(int years) {
    return 'Age: $years years';
  }

  @override
  String bmiLabel(String value) {
    return 'BMI: $value';
  }

  @override
  String get myDiets => 'My Diets';

  @override
  String get myWorkouts => 'My Workouts';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get headerDiets => '--- DIETS MODULE ---';

  @override
  String get dietsTitle => 'My Diets';

  @override
  String get noDietsMessage => 'No diets yet. Create your first one!';

  @override
  String get createDiet => 'Create Diet';

  @override
  String get featureInProgress => 'Creation form in progress...';

  @override
  String get createDietTitle => 'Create new diet';

  @override
  String get dietName => 'Diet name';

  @override
  String get dietObjective => 'Main objective';

  @override
  String get dietAllergies => 'Allergies or intolerances (Optional)';

  @override
  String get dietAdditionalData => 'Additional data (Optional)';

  @override
  String get weightLoss => 'Weight loss';

  @override
  String get muscleGain => 'Muscle gain';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get dietCreatedSuccess => 'Diet created successfully!';

  @override
  String get dietAllergiesHint => 'Ex: Peanuts, lactose...';

  @override
  String get dietAdditionalDataHint => 'Ex: I don\'t like broccoli';

  @override
  String get headerTrainings => '--- TRAINING MODULE ---';

  @override
  String get trainingsTitle => 'My Trainings';

  @override
  String get noTrainingsMessage => 'No routines yet. Create your first one!';

  @override
  String get createTraining => 'Create Routine';

  @override
  String get createTrainingTitle => 'Create new routine';

  @override
  String get trainingName => 'Routine name';

  @override
  String get trainingObjective => 'Main objective';

  @override
  String get hypertrophy => 'Hypertrophy';

  @override
  String get strength => 'Strength';

  @override
  String get endurance => 'Endurance';

  @override
  String maxDaysLabel(int days) {
    return 'Days per week: $days';
  }

  @override
  String maxTimeLabel(int minutes) {
    return 'Time per session: $minutes min';
  }

  @override
  String get trainingCreatedSuccess => 'Routine created successfully!';
}
