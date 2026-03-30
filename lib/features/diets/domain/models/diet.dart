/// Represents a dietary plan assigned to a specific user profile.
class Diet {
  /// Unique identifier for the diet (Auto-incremented by SQLite).
  final int? idDiet;

  /// Foreign key linking this diet to a specific user profile.
  final int idProfile;

  /// The descriptive name of the diet (e.g., "Summer Cutting Phase").
  final String name;

  /// The main goal of the diet (e.g., "Weight Loss", "Muscle Gain").
  final String objective;

  /// Optional field detailing any food allergies or intolerances.
  final String? allergies;

  /// Optional field for extra instructions or nutritional preferences.
  final String? additionalData;

  const Diet({
    this.idDiet,
    required this.idProfile,
    required this.name,
    required this.objective,
    this.allergies,
    this.additionalData,
  });

  /// Converts a [Diet] instance into a Map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'id_diet': idDiet,
      'id_profile': idProfile,
      'name': name,
      'objective': objective,
      'allergies': allergies,
      'additional_data': additionalData,
    };
  }

  /// Constructs a [Diet] instance from a SQLite Map object.
  factory Diet.fromMap(Map<String, dynamic> map) {
    return Diet(
      idDiet: map['id_diet'] as int?,
      idProfile: map['id_profile'] as int,
      name: map['name'] as String,
      objective: map['objective'] as String,
      allergies: map['allergies'] as String?,
      additionalData: map['additional_data'] as String?,
    );
  }
}