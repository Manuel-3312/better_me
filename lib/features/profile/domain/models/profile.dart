class Profile {
  final int? idProfile;
  final String sex;
  final double weight;
  final double height;
  final DateTime birthDate;

  double get caloricExpenditure {
    // TODO: Implementar aquí la fórmula de Harris-Benedict o similar
    return 0.0;
  }

  Profile({
    this.idProfile,
    required this.sex,
    required this.weight,
    required this.height,
    required this.birthDate,
  });
}