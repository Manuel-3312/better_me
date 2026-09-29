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
  String get myDiets => 'Diets';

  @override
  String get myWorkouts => 'Workouts';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get headerDiets => '--- DIETS MODULE ---';

  @override
  String get dietsTitle => 'Diets';

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
  String get trainingsTitle => 'Trainings';

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

  @override
  String get generatingDiet => 'Generating your personalized plan...';

  @override
  String get errorGeneratingDiet =>
      'Failed to generate the diet plan. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get noDietData => 'No diet data available.';

  @override
  String dayNumber(int number) {
    return 'Day $number';
  }

  @override
  String get kcal => 'kcal';

  @override
  String get generatingTraining => 'Designing your ideal routine...';

  @override
  String get errorGeneratingTraining =>
      'Failed to generate the routine. Please try again.';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get rest => 'Rest';

  @override
  String get seconds => 's';

  @override
  String get noTrainingData => 'No training data available.';

  @override
  String get setupPlanTitle => 'Setup Plan';

  @override
  String get todayTitle => 'Today';

  @override
  String get changeActivePlan => 'Change active plan';

  @override
  String get chooseCurrentFocus => 'Choose your current focus';

  @override
  String get setupPlanDescription =>
      'Select which diet and training routine you want to follow day by day.';

  @override
  String get activeDiet => 'Active Diet';

  @override
  String get selectDietHint => 'Select a diet';

  @override
  String get activeTraining => 'Active Training';

  @override
  String get selectTrainingHint => 'Select a training';

  @override
  String get saveAndStart => 'Save and Start';

  @override
  String get yourMeals => 'Your Meals';

  @override
  String get noDietDataForToday => 'No diet data for today.';

  @override
  String get yourTraining => 'Your Training';

  @override
  String get restDayOrNoData => 'Rest day or no data available.';

  @override
  String scheduledExercises(int count) {
    return '$count scheduled exercises';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get generatingAiPlan => 'Generating AI plan...';

  @override
  String daysPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days/week',
      one: '1 day/week',
    );
    return '$_temp0';
  }

  @override
  String get cookingAiPlan => 'Cooking your AI plan...';

  @override
  String get logWeightTitle => 'Log current weight';

  @override
  String get invalidWeight => 'Please enter a valid weight';

  @override
  String get weightHistory => 'Weight history';

  @override
  String get nightMode => 'Night Mode';

  @override
  String get switchProfile => 'Switch Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get save => 'Save';

  @override
  String get years => 'Years';

  @override
  String get restDayTitle => 'Rest Day';

  @override
  String get restDayMessage =>
      'Your muscles grow while you rest. Enjoy your recovery time and recharge your energy for the next workout.';

  @override
  String get deleteTrainingTitle => 'Delete Training';

  @override
  String get deleteTrainingContent =>
      'Are you sure you want to delete this training plan?';

  @override
  String get deleteDietTitle => 'Delete Diet';

  @override
  String get deleteDietContent => 'Are you sure you want to delete this diet?';

  @override
  String get deleteEntryTitle => 'Delete Entry';

  @override
  String get deleteEntryContent =>
      'Are you sure you want to delete this progress log?';

  @override
  String entryDeleted(String date) {
    return 'Entry from $date deleted';
  }

  @override
  String dietDeleted(String name) {
    return '$name deleted';
  }

  @override
  String trainingDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get noProgressLogged => 'No progress logged yet.';

  @override
  String get logProgress => 'Log Progress';

  @override
  String get progressTimelineTitle => 'Progress Timeline';

  @override
  String get minutes => 'min';

  @override
  String get dateLabel => 'Date';

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get progressPhotos => 'Progress Photos';

  @override
  String get addButton => 'Add';

  @override
  String get noPhotosAdded => 'No photos added';

  @override
  String get saveProgress => 'Save Progress';

  @override
  String get saveProgressError => 'Failed to save progress';

  @override
  String get trackTransformation => 'Track your body transformation';

  @override
  String weightDisplay(double weight) {
    final intl.NumberFormat weightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weightString = weightNumberFormat.format(weight);

    return '$weightString kg';
  }

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fats => 'Fats';

  @override
  String get recipe => 'Recipe';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get macros => 'Macros';

  @override
  String get close => 'Close';

  @override
  String get total => 'Total';

  @override
  String get settings => 'Settings';

  @override
  String get favoriteExercisesTitle => 'Favorite Exercises';

  @override
  String get includeInAiPlans => 'Include in future AI Plans';

  @override
  String get aiPrioritizeDesc =>
      'AI will try to prioritize these exercises for the target muscle.';

  @override
  String get noFavoritesMessage => 'No favorite exercises yet.';

  @override
  String get cookbookTitle => 'Cookbook';

  @override
  String get includeInAiDiets => 'Include in future AI Diets';

  @override
  String get aiPrioritizeMealsDesc =>
      'AI will try to prioritize these meals if they match your macros.';

  @override
  String get cookbookEmpty => 'Your cookbook is empty.';

  @override
  String get languageWarning =>
      'Note: The selected language will be used by the AI to generate your personalized diet and training plans.';

  @override
  String get workoutRoutineTitle => 'Workout Routine';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get unknownExercise => 'Unknown exercise';

  @override
  String get setLabel => 'Set';

  @override
  String get repsLabel => 'reps';

  @override
  String get restAction => 'Rest';

  @override
  String get restTitle => 'Rest Time';

  @override
  String get nextExerciseLabel => 'Next exercise:';

  @override
  String get skipRestAction => 'Skip rest';

  @override
  String get stopWorkoutConfirm => 'Are you sure you want to stop the workout?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get workoutCompletedTitle => 'Workout Completed!!!';

  @override
  String get backToMenuAction => 'Back to menu';

  @override
  String get musclesTargeted => 'Muscles Targeted';

  @override
  String get exerciseDetails => 'Exercise Details';

  @override
  String get logout => 'Log out';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutContent =>
      'Are you sure you want to log out? You will need to enter your credentials again to access your account.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create your account';

  @override
  String get loginSubtitle => 'Log in to continue your progress';

  @override
  String get registerSubtitle => 'Join BetterMe and transform your life';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'LOG IN';

  @override
  String get registerButton => 'SIGN UP';

  @override
  String get noAccountPrompt => 'Don\'t have an account? Sign up here';

  @override
  String get hasAccountPrompt => 'Already have an account? Log in';

  @override
  String get fillAllFields => 'Please fill in all fields.';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get searchRoutine => 'Find a routine or a goal...';

  @override
  String get searchDiet => 'Find a diet or a goal...';

  @override
  String get dailyReminders => 'Daily Reminders';

  @override
  String get noRemindersSet => 'No reminders set';

  @override
  String get newReminder => 'New Reminder';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'e.g., Creatine';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get descriptionHint => 'e.g., 5g with water';

  @override
  String get time => 'Time';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String get dailyDesc => 'Manage supplements and tasks';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
}
