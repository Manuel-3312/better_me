class Profile {
  final int? idProfile;
  final String name; // mockup
  final String sex;
  final double weight;
  final double height;
  final DateTime birthDate;

  Profile({
    this.idProfile,
    required this.name,
    required this.sex,
    required this.weight,
    required this.height,
    required this.birthDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_profile': idProfile,
      'name': name, // mockup
      'sex': sex,
      'weight': weight,
      'height': height,
      'birth_date': birthDate.toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      idProfile: map['id_profile'],
      name: map['name'] ?? '', // mockup
      sex: map['sex'],
      weight: map['weight'],
      height: map['height'],
      birthDate: DateTime.parse(map['birth_date']),
    );
  }
}