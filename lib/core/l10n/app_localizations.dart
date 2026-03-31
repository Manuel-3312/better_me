import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @headerWelcome.
  ///
  /// In es, this message translates to:
  /// **'--- PANTALLA DE BIENVENIDA ---'**
  String get headerWelcome;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a BetterMe'**
  String get welcomeTitle;

  /// No description provided for @swipeToStart.
  ///
  /// In es, this message translates to:
  /// **'Desliza hacia arriba para empezar'**
  String get swipeToStart;

  /// No description provided for @changeLanguage.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma'**
  String get changeLanguage;

  /// No description provided for @headerProfile.
  ///
  /// In es, this message translates to:
  /// **'--- GESTIÓN DE PERFIL ---'**
  String get headerProfile;

  /// No description provided for @createProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Añade tus datos'**
  String get createProfileTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfileTitle;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @sex.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get sex;

  /// No description provided for @weight.
  ///
  /// In es, this message translates to:
  /// **'Peso (Kg)'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In es, this message translates to:
  /// **'Altura (cm)'**
  String get height;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @createButton.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get createButton;

  /// No description provided for @updateButton.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get updateButton;

  /// No description provided for @profileCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Perfil creado con éxito!'**
  String get profileCreatedSuccess;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Perfil actualizado con éxito!'**
  String get profileUpdatedSuccess;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get requiredField;

  /// No description provided for @selectDateWarning.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona tu fecha de nacimiento'**
  String get selectDateWarning;

  /// No description provided for @male.
  ///
  /// In es, this message translates to:
  /// **'Hombre'**
  String get male;

  /// No description provided for @female.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get female;

  /// No description provided for @headerSelection.
  ///
  /// In es, this message translates to:
  /// **'--- SELECCIÓN DE PERFIL ---'**
  String get headerSelection;

  /// No description provided for @chooseProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tu perfil'**
  String get chooseProfileTitle;

  /// No description provided for @createProfileButton.
  ///
  /// In es, this message translates to:
  /// **'Crear perfil'**
  String get createProfileButton;

  /// No description provided for @noProfilesMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay perfiles. ¡Crea el primero!'**
  String get noProfilesMessage;

  /// No description provided for @profileSelected.
  ///
  /// In es, this message translates to:
  /// **'Has seleccionado a {profileName}'**
  String profileSelected(String profileName);

  /// No description provided for @deleteProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar perfil'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileContent.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar a {profileName}?'**
  String deleteProfileContent(String profileName);

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @profileDeleted.
  ///
  /// In es, this message translates to:
  /// **'Perfil eliminado'**
  String get profileDeleted;

  /// No description provided for @undo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// No description provided for @headerDashboard.
  ///
  /// In es, this message translates to:
  /// **'--- DASHBOARD ---'**
  String get headerDashboard;

  /// No description provided for @dashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel de Control'**
  String get dashboardTitle;

  /// No description provided for @welcomeUser.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {name}!'**
  String welcomeUser(String name);

  /// No description provided for @ageLabel.
  ///
  /// In es, this message translates to:
  /// **'Edad: {years} años'**
  String ageLabel(int years);

  /// No description provided for @bmiLabel.
  ///
  /// In es, this message translates to:
  /// **'IMC: {value}'**
  String bmiLabel(String value);

  /// No description provided for @myDiets.
  ///
  /// In es, this message translates to:
  /// **'Dietas'**
  String get myDiets;

  /// No description provided for @myWorkouts.
  ///
  /// In es, this message translates to:
  /// **'Rutinas'**
  String get myWorkouts;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @headerDiets.
  ///
  /// In es, this message translates to:
  /// **'--- MÓDULO DE DIETAS ---'**
  String get headerDiets;

  /// No description provided for @dietsTitle.
  ///
  /// In es, this message translates to:
  /// **'Dietas'**
  String get dietsTitle;

  /// No description provided for @noDietsMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay dietas. ¡Crea la primera!'**
  String get noDietsMessage;

  /// No description provided for @createDiet.
  ///
  /// In es, this message translates to:
  /// **'Crear Dieta'**
  String get createDiet;

  /// No description provided for @featureInProgress.
  ///
  /// In es, this message translates to:
  /// **'Formulario de creación en progreso...'**
  String get featureInProgress;

  /// No description provided for @createDietTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva dieta'**
  String get createDietTitle;

  /// No description provided for @dietName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la dieta'**
  String get dietName;

  /// No description provided for @dietObjective.
  ///
  /// In es, this message translates to:
  /// **'Objetivo principal'**
  String get dietObjective;

  /// No description provided for @dietAllergies.
  ///
  /// In es, this message translates to:
  /// **'Alergias o intolerancias (Opcional)'**
  String get dietAllergies;

  /// No description provided for @dietAdditionalData.
  ///
  /// In es, this message translates to:
  /// **'Datos adicionales (Opcional)'**
  String get dietAdditionalData;

  /// No description provided for @weightLoss.
  ///
  /// In es, this message translates to:
  /// **'Pérdida de peso'**
  String get weightLoss;

  /// No description provided for @muscleGain.
  ///
  /// In es, this message translates to:
  /// **'Ganancia muscular'**
  String get muscleGain;

  /// No description provided for @maintenance.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get maintenance;

  /// No description provided for @dietCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Dieta creada con éxito!'**
  String get dietCreatedSuccess;

  /// No description provided for @dietAllergiesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Cacahuetes, lactosa...'**
  String get dietAllergiesHint;

  /// No description provided for @dietAdditionalDataHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: No me gusta el brócoli'**
  String get dietAdditionalDataHint;

  /// No description provided for @headerTrainings.
  ///
  /// In es, this message translates to:
  /// **'--- MÓDULO DE ENTRENAMIENTO ---'**
  String get headerTrainings;

  /// No description provided for @trainingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Entrenamientos'**
  String get trainingsTitle;

  /// No description provided for @noTrainingsMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay rutinas. ¡Crea la primera!'**
  String get noTrainingsMessage;

  /// No description provided for @createTraining.
  ///
  /// In es, this message translates to:
  /// **'Crear Rutina'**
  String get createTraining;

  /// No description provided for @createTrainingTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva rutina'**
  String get createTrainingTitle;

  /// No description provided for @trainingName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la rutina'**
  String get trainingName;

  /// No description provided for @trainingObjective.
  ///
  /// In es, this message translates to:
  /// **'Objetivo principal'**
  String get trainingObjective;

  /// No description provided for @hypertrophy.
  ///
  /// In es, this message translates to:
  /// **'Hipertrofia'**
  String get hypertrophy;

  /// No description provided for @strength.
  ///
  /// In es, this message translates to:
  /// **'Fuerza'**
  String get strength;

  /// No description provided for @endurance.
  ///
  /// In es, this message translates to:
  /// **'Resistencia'**
  String get endurance;

  /// No description provided for @maxDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días por semana: {days}'**
  String maxDaysLabel(int days);

  /// No description provided for @maxTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo por sesión: {minutes} min'**
  String maxTimeLabel(int minutes);

  /// No description provided for @trainingCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Rutina creada con éxito!'**
  String get trainingCreatedSuccess;

  /// No description provided for @generatingDiet.
  ///
  /// In es, this message translates to:
  /// **'Generando tu plan personalizado...'**
  String get generatingDiet;

  /// No description provided for @errorGeneratingDiet.
  ///
  /// In es, this message translates to:
  /// **'Error al generar la dieta. Inténtalo de nuevo.'**
  String get errorGeneratingDiet;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @noDietData.
  ///
  /// In es, this message translates to:
  /// **'No hay datos de dieta disponibles.'**
  String get noDietData;

  /// No description provided for @dayNumber.
  ///
  /// In es, this message translates to:
  /// **'Día {number}'**
  String dayNumber(int number);

  /// No description provided for @kcal.
  ///
  /// In es, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @generatingTraining.
  ///
  /// In es, this message translates to:
  /// **'Diseñando tu rutina ideal...'**
  String get generatingTraining;

  /// No description provided for @errorGeneratingTraining.
  ///
  /// In es, this message translates to:
  /// **'Error al generar la rutina. Inténtalo de nuevo.'**
  String get errorGeneratingTraining;

  /// No description provided for @sets.
  ///
  /// In es, this message translates to:
  /// **'Series'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In es, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @rest.
  ///
  /// In es, this message translates to:
  /// **'Descanso'**
  String get rest;

  /// No description provided for @seconds.
  ///
  /// In es, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @noTrainingData.
  ///
  /// In es, this message translates to:
  /// **'No hay datos de entrenamiento disponibles.'**
  String get noTrainingData;

  /// No description provided for @setupPlanTitle.
  ///
  /// In es, this message translates to:
  /// **'Configurar Plan'**
  String get setupPlanTitle;

  /// No description provided for @todayTitle.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get todayTitle;

  /// No description provided for @changeActivePlan.
  ///
  /// In es, this message translates to:
  /// **'Cambiar plan activo'**
  String get changeActivePlan;

  /// No description provided for @chooseCurrentFocus.
  ///
  /// In es, this message translates to:
  /// **'Elige tu enfoque actual'**
  String get chooseCurrentFocus;

  /// No description provided for @setupPlanDescription.
  ///
  /// In es, this message translates to:
  /// **'Selecciona qué dieta y rutina de entrenamiento quieres seguir día a día.'**
  String get setupPlanDescription;

  /// No description provided for @activeDiet.
  ///
  /// In es, this message translates to:
  /// **'Dieta Activa'**
  String get activeDiet;

  /// No description provided for @selectDietHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una dieta'**
  String get selectDietHint;

  /// No description provided for @activeTraining.
  ///
  /// In es, this message translates to:
  /// **'Entrenamiento Activo'**
  String get activeTraining;

  /// No description provided for @selectTrainingHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una rutina'**
  String get selectTrainingHint;

  /// No description provided for @saveAndStart.
  ///
  /// In es, this message translates to:
  /// **'Guardar y Empezar'**
  String get saveAndStart;

  /// No description provided for @yourMeals.
  ///
  /// In es, this message translates to:
  /// **'Tus Comidas'**
  String get yourMeals;

  /// No description provided for @noDietDataForToday.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de dieta para hoy.'**
  String get noDietDataForToday;

  /// No description provided for @yourTraining.
  ///
  /// In es, this message translates to:
  /// **'Tu Entrenamiento'**
  String get yourTraining;

  /// No description provided for @restDayOrNoData.
  ///
  /// In es, this message translates to:
  /// **'Día de descanso o sin datos.'**
  String get restDayOrNoData;

  /// No description provided for @scheduledExercises.
  ///
  /// In es, this message translates to:
  /// **'{count} ejercicios programados'**
  String scheduledExercises(int count);

  /// No description provided for @monday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get sunday;

  /// No description provided for @generatingAiPlan.
  ///
  /// In es, this message translates to:
  /// **'Generando plan con IA...'**
  String get generatingAiPlan;

  /// No description provided for @daysPerWeek.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1 {1 día/semana} other {{count} días/semana}}'**
  String daysPerWeek(int count);

  /// No description provided for @cookingAiPlan.
  ///
  /// In es, this message translates to:
  /// **'Cocinando tu plan con IA...'**
  String get cookingAiPlan;

  /// No description provided for @logWeightTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar peso actual'**
  String get logWeightTitle;

  /// No description provided for @invalidWeight.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un peso válido'**
  String get invalidWeight;

  /// No description provided for @weightHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de peso'**
  String get weightHistory;

  /// No description provided for @nightMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Noche'**
  String get nightMode;

  /// No description provided for @switchProfile.
  ///
  /// In es, this message translates to:
  /// **'Cambiar Perfil'**
  String get switchProfile;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
