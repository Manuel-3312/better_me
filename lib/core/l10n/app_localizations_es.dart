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
}
