// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get headerWelcome => '--- PANTALLA BIENVENIDA ---';

  @override
  String get welcomeTitle => 'Bienvenido a BetterMe';

  @override
  String get swipeToStart => 'Desliza hacia arriba para comenzar';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get headerProfile => '--- GESTIÓN DE PERFIL ---';

  @override
  String get createProfileTitle => 'Agrega tus datos';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get sex => 'Sexo';

  @override
  String get weight => 'Peso (Kg)';

  @override
  String get height => 'Altura (cm)';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get createButton => 'Crear';

  @override
  String get updateButton => 'Actualizar';

  @override
  String get profileCreatedSuccess => '¡Perfil creado con éxito!';

  @override
  String get profileUpdatedSuccess => '¡Perfil actualizado con éxito!';

  @override
  String get requiredField => 'Campo requerido';

  @override
  String get selectDateWarning =>
      'Por favor, selecciona tu fecha de nacimiento';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get headerSelection => '--- SELECCIÓN DE PERFIL ---';

  @override
  String get chooseProfileTitle => 'Elige tu perfil';

  @override
  String get createProfileButton => 'Crear perfil';

  @override
  String get noProfilesMessage => 'No hay perfiles aún. ¡Crea el primero!';

  @override
  String profileSelected(String profileName) {
    return 'Seleccionaste a $profileName';
  }

  @override
  String get deleteProfileTitle => 'Eliminar perfil';

  @override
  String deleteProfileContent(String profileName) {
    return '¿Estás seguro de que deseas eliminar a $profileName?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get profileDeleted => 'Perfil eliminado';

  @override
  String get undo => 'Deshacer';

  @override
  String get headerDashboard => '--- PANEL DE CONTROL ---';

  @override
  String get dashboardTitle => 'Resumen';

  @override
  String welcomeUser(String name) {
    return '¡Hola, $name!';
  }

  @override
  String ageLabel(int years) {
    return 'Edad: $years años';
  }

  @override
  String bmiLabel(String value) {
    return 'IMC: $value';
  }

  @override
  String get myDiets => 'Mis Dietas';

  @override
  String get myWorkouts => 'Mis Entrenamientos';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get headerDiets => '--- MÓDULO DE DIETAS ---';

  @override
  String get dietsTitle => 'Mis Dietas';

  @override
  String get noDietsMessage => 'Aún no tienes dietas. ¡Crea la primera!';

  @override
  String get createDiet => 'Crear Dieta';

  @override
  String get featureInProgress => 'Formulario de creación en progreso...';

  @override
  String get createDietTitle => 'Crear nueva dieta';

  @override
  String get dietName => 'Nombre de la dieta';

  @override
  String get dietObjective => 'Objetivo principal';

  @override
  String get dietAllergies => 'Alergias o intolerancias (Opcional)';

  @override
  String get dietAdditionalData => 'Datos adicionales (Opcional)';

  @override
  String get weightLoss => 'Pérdida de peso';

  @override
  String get muscleGain => 'Ganancia muscular';

  @override
  String get maintenance => 'Mantenimiento';

  @override
  String get dietCreatedSuccess => '¡Dieta creada con éxito!';

  @override
  String get dietAllergiesHint => 'Ej: Cacahuetes, lactosa...';

  @override
  String get dietAdditionalDataHint => 'Ej: No me gusta el brócoli';

  @override
  String get headerTrainings => '--- MÓDULO DE ENTRENAMIENTOS ---';

  @override
  String get trainingsTitle => 'Mis Entrenamientos';

  @override
  String get noTrainingsMessage => 'Aún no tienes rutinas. ¡Crea la primera!';

  @override
  String get createTraining => 'Crear Rutina';

  @override
  String get createTrainingTitle => 'Crear nueva rutina';

  @override
  String get trainingName => 'Nombre de la rutina';

  @override
  String get trainingObjective => 'Objetivo principal';

  @override
  String get hypertrophy => 'Hipertrofia';

  @override
  String get strength => 'Fuerza';

  @override
  String get endurance => 'Resistencia';

  @override
  String maxDaysLabel(int days) {
    return 'Días por semana: $days';
  }

  @override
  String maxTimeLabel(int minutes) {
    return 'Tiempo por sesión: $minutes min';
  }

  @override
  String get trainingCreatedSuccess => '¡Rutina creada con éxito!';
}
