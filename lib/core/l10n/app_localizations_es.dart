// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get createProfileTitle => 'Agrega tus datos';

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
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get requiredField => 'Campo requerido';

  @override
  String get profileCreatedSuccess => '¡Perfil creado con éxito!';

  @override
  String get selectDateWarning =>
      'Por favor, selecciona tu fecha de nacimiento';

  @override
  String get welcomeTitle => 'Bienvenido a BetterMe';

  @override
  String get swipeToStart => 'Desliza hacia arriba para comenzar';

  @override
  String get changeLanguage => 'Cambiar idioma';

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
  String get editProfileTitle => 'Editar perfil';

  @override
  String get updateButton => 'Actualizar';

  @override
  String get profileUpdatedSuccess => '¡Perfil actualizado con éxito!';
}
