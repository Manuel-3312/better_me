// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get headerWelcome => '--- PANTALLA DE BIENVENIDA ---';

  @override
  String get welcomeTitle => 'Bienvenido a BetterMe';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get headerProfile => '--- GESTIÓN DE PERFIL ---';

  @override
  String get createProfileTitle => 'Añade tus datos';

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
  String get requiredField => 'Campo obligatorio';

  @override
  String get selectDateWarning =>
      'Por favor, selecciona tu fecha de nacimiento';

  @override
  String get male => 'Hombre';

  @override
  String get female => 'Mujer';

  @override
  String get headerSelection => '--- SELECCIÓN DE PERFIL ---';

  @override
  String get chooseProfileTitle => 'Elige tu perfil';

  @override
  String get createProfileButton => 'Crear perfil';

  @override
  String get noProfilesMessage => 'Aún no hay perfiles. ¡Crea el primero!';

  @override
  String profileSelected(String profileName) {
    return 'Has seleccionado a $profileName';
  }

  @override
  String get deleteProfileTitle => 'Eliminar perfil';

  @override
  String deleteProfileContent(String profileName) {
    return '¿Estás seguro de que quieres eliminar a $profileName?';
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
  String get headerDashboard => '--- DASHBOARD ---';

  @override
  String get dashboardTitle => 'Panel de Control';

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
  String get myDiets => 'Dietas';

  @override
  String get myWorkouts => 'Rutinas';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get headerDiets => '--- MÓDULO DE DIETAS ---';

  @override
  String get dietsTitle => 'Dietas';

  @override
  String get noDietsMessage => 'Aún no hay dietas. ¡Crea la primera!';

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
  String get headerTrainings => '--- MÓDULO DE ENTRENAMIENTO ---';

  @override
  String get trainingsTitle => 'Entrenamientos';

  @override
  String get noTrainingsMessage => 'Aún no hay rutinas. ¡Crea la primera!';

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

  @override
  String get generatingDiet => 'Generando tu plan personalizado...';

  @override
  String get errorGeneratingDiet =>
      'Error al generar la dieta. Inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get noDietData => 'No hay datos de dieta disponibles.';

  @override
  String dayNumber(int number) {
    return 'Día $number';
  }

  @override
  String get kcal => 'kcal';

  @override
  String get generatingTraining => 'Diseñando tu rutina ideal...';

  @override
  String get errorGeneratingTraining =>
      'Error al generar la rutina. Inténtalo de nuevo.';

  @override
  String get sets => 'Series';

  @override
  String get reps => 'Reps';

  @override
  String get rest => 'Descanso';

  @override
  String get seconds => 's';

  @override
  String get noTrainingData => 'No hay datos de entrenamiento disponibles.';

  @override
  String get setupPlanTitle => 'Configurar Plan';

  @override
  String get todayTitle => 'Hoy';

  @override
  String get changeActivePlan => 'Cambiar plan activo';

  @override
  String get chooseCurrentFocus => 'Elige tu enfoque actual';

  @override
  String get setupPlanDescription =>
      'Selecciona qué dieta y rutina de entrenamiento quieres seguir día a día.';

  @override
  String get activeDiet => 'Dieta Activa';

  @override
  String get selectDietHint => 'Selecciona una dieta';

  @override
  String get activeTraining => 'Entrenamiento Activo';

  @override
  String get selectTrainingHint => 'Selecciona una rutina';

  @override
  String get saveAndStart => 'Guardar y Empezar';

  @override
  String get yourMeals => 'Tus Comidas';

  @override
  String get noDietDataForToday => 'Sin datos de dieta para hoy.';

  @override
  String get yourTraining => 'Tu Entrenamiento';

  @override
  String get restDayOrNoData => 'Día de descanso o sin datos.';

  @override
  String scheduledExercises(int count) {
    return '$count ejercicios programados';
  }

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get generatingAiPlan => 'Generando plan con IA...';

  @override
  String daysPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días/semana',
      one: '1 día/semana',
    );
    return '$_temp0';
  }

  @override
  String get cookingAiPlan => 'Cocinando tu plan con IA...';

  @override
  String get logWeightTitle => 'Registrar peso actual';

  @override
  String get invalidWeight => 'Por favor, introduce un peso válido';

  @override
  String get weightHistory => 'Historial de peso';

  @override
  String get nightMode => 'Modo Noche';

  @override
  String get switchProfile => 'Cambiar Perfil';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get save => 'Guardar';

  @override
  String get years => 'Years';

  @override
  String get restDayTitle => 'Día de Descanso';

  @override
  String get restDayMessage =>
      'Tus músculos crecen mientras descansas. Disfruta de tu tiempo de recuperación y recarga energías para el próximo entrenamiento.';

  @override
  String get deleteTrainingTitle => 'Eliminar Entrenamiento';

  @override
  String get deleteTrainingContent =>
      '¿Estás seguro de que quieres eliminar este plan de entrenamiento?';

  @override
  String get deleteDietTitle => 'Eliminar Dieta';

  @override
  String get deleteDietContent =>
      '¿Estás seguro de que quieres eliminar esta dieta?';

  @override
  String get deleteEntryTitle => 'Eliminar Entrada';

  @override
  String get deleteEntryContent =>
      '¿Estás seguro de que quieres eliminar este registro de progreso?';

  @override
  String entryDeleted(String date) {
    return 'Entrada del $date eliminada';
  }

  @override
  String dietDeleted(String name) {
    return '$name eliminada';
  }

  @override
  String trainingDeleted(String name) {
    return '$name eliminado';
  }

  @override
  String get noProgressLogged => 'Aún no hay progreso registrado.';

  @override
  String get logProgress => 'Registrar Progreso';

  @override
  String get progressTimelineTitle => 'Progreso';

  @override
  String get minutes => 'min';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get weightKgLabel => 'Peso (kg)';

  @override
  String get invalidNumber => 'Ingrese un número válido';

  @override
  String get progressPhotos => 'Fotos de progreso';

  @override
  String get addButton => 'Añadir';

  @override
  String get noPhotosAdded => 'No hay fotos añadidas';

  @override
  String get saveProgress => 'Guardar progreso';

  @override
  String get saveProgressError => 'Error al guardar el progreso';

  @override
  String get trackTransformation => 'Sigue tu transformación corporal';

  @override
  String weightDisplay(double weight) {
    final intl.NumberFormat weightNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weightString = weightNumberFormat.format(weight);

    return '$weightString kg';
  }

  @override
  String get protein => 'Proteínas';

  @override
  String get carbs => 'Carbohidratos';

  @override
  String get fats => 'Grasas';

  @override
  String get recipe => 'Receta';

  @override
  String get ingredients => 'Ingredientes';

  @override
  String get instructions => 'Instrucciones';

  @override
  String get macros => 'Macros';

  @override
  String get close => 'Cerrar';

  @override
  String get total => 'Total';

  @override
  String get settings => 'Ajustes';

  @override
  String get favoriteExercisesTitle => 'Ejercicios Favoritos';

  @override
  String get includeInAiPlans => 'Incluir en planes de IA futuros';

  @override
  String get aiPrioritizeDesc =>
      'La IA intentará priorizar estos ejercicios para el músculo objetivo.';

  @override
  String get noFavoritesMessage => 'No hay ejercicios favoritos aún.';

  @override
  String get cookbookTitle => 'Libro de Cocina';

  @override
  String get includeInAiDiets => 'Incluir en futuros planes de IA';

  @override
  String get aiPrioritizeMealsDesc =>
      'La IA intentará priorizar estas comidas si coinciden con tus macros.';

  @override
  String get cookbookEmpty => 'Tu libro de cocina está vacío.';

  @override
  String get languageWarning =>
      'Nota: El idioma seleccionado será el que utilice la IA para generar tus planes de dieta y entrenamiento personalizados.';
}
