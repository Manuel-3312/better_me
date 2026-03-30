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
  /// **'--- PANTALLA BIENVENIDA ---'**
  String get headerWelcome;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a BetterMe'**
  String get welcomeTitle;

  /// No description provided for @swipeToStart.
  ///
  /// In es, this message translates to:
  /// **'Desliza hacia arriba para comenzar'**
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
  /// **'Agrega tus datos'**
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
  /// **'Campo requerido'**
  String get requiredField;

  /// No description provided for @selectDateWarning.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona tu fecha de nacimiento'**
  String get selectDateWarning;

  /// No description provided for @male.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get male;

  /// No description provided for @female.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
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
  /// **'No hay perfiles aún. ¡Crea el primero!'**
  String get noProfilesMessage;

  /// No description provided for @profileSelected.
  ///
  /// In es, this message translates to:
  /// **'Seleccionaste a {profileName}'**
  String profileSelected(String profileName);

  /// No description provided for @deleteProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar perfil'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileContent.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar a {profileName}?'**
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
  /// **'--- PANEL DE CONTROL ---'**
  String get headerDashboard;

  /// No description provided for @dashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
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
  /// **'Mis Dietas'**
  String get myDiets;

  /// No description provided for @myWorkouts.
  ///
  /// In es, this message translates to:
  /// **'Mis Entrenamientos'**
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
  /// **'Mis Dietas'**
  String get dietsTitle;

  /// No description provided for @noDietsMessage.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes dietas. ¡Crea la primera!'**
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
