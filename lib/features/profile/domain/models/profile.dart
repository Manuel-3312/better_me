class Profile {
  final int? idProfile;
  final String sex;
  final double weight;
  final double height;
  final DateTime birthDate;

  double get caloricExpenditure {
    return 0.0;
  }

  Profile({
    this.idProfile,
    required this.sex,
    required this.weight,
    required this.height,
    required this.birthDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_profile': idProfile,
      'sex': sex,
      'weight': weight,
      'height': height,
      'birth_date': birthDate.toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      idProfile: map['id_profile'],
      sex: map['sex'],
      weight: map['weight'],
      height: map['height'],
      birthDate: DateTime.parse(map['birth_date']),
    );
  }
}
