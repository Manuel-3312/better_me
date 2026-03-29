class Diet {
  final int? idDiet;
  final int idProfile;
  final String name;
  final String objective;
  final String? allergies;
  final String? additionalData;

  Diet({
    this.idDiet,
    required this.idProfile,
    required this.name,
    required this.objective,
    this.allergies,
    this.additionalData,
  });
}
