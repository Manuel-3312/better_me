/// Represents a user profile containing biometrics and active plan preferences.
class Profile {
  /// Unique identifier for the profile.
  final int? idProfile;

  /// The user's unique identifier.
  final String userId;

  /// The user's name.
  final String name;

  /// The user's biological sex.
  final String sex;

  /// The user's weight in kilograms.
  final double weight;

  /// The user's height in centimeters.
  final double height;

  /// The user's date of birth.
  final DateTime birthDate;

  /// Foreign key referencing the currently active diet. Null if none is set.
  final int? activeDietId;

  /// Foreign key referencing the currently active training. Null if none is set.
  final int? activeTrainingId;

  const Profile({
    this.idProfile,
    required this.userId,
    required this.name,
    required this.sex,
    required this.weight,
    required this.height,
    required this.birthDate,
    this.activeDietId,
    this.activeTrainingId,
  });

  /// Converts a [Profile] instance into a Map for SQLite insertion/update.
  Map<String, dynamic> toMap() {
    return {
      'id_profile': idProfile,
      'user_id': userId,
      'name': name,
      'sex': sex,
      'weight': weight,
      'height': height,
      'birth_date': birthDate.toIso8601String(),
      'active_diet_id': activeDietId,
      'active_training_id': activeTrainingId,
    };
  }

  /// Constructs a [Profile] instance from a SQLite Map object.
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      idProfile: map['id_profile'] as int?,
      userId: map['user_id'] ?? '',
      name: map['name'] as String,
      sex: map['sex'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      birthDate: DateTime.parse(map['birth_date'] as String),
      activeDietId: map['active_diet_id'] as int?,
      activeTrainingId: map['active_training_id'] as int?,
    );
  }

  /// Creates a copy of this [Profile] but with the given fields replaced with the new values.
  Profile copyWith({
    int? idProfile,
    String? userId,
    String? name,
    String? sex,
    double? weight,
    double? height,
    DateTime? birthDate,
    int? activeDietId,
    int? activeTrainingId,
  }) {
    return Profile(
      idProfile: idProfile ?? this.idProfile,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      birthDate: birthDate ?? this.birthDate,
      // We use a specific approach to allow nullifying these fields if needed,
      // but for simplicity, we just assign them here.
      activeDietId: activeDietId ?? this.activeDietId,
      activeTrainingId: activeTrainingId ?? this.activeTrainingId,
    );
  }
}
