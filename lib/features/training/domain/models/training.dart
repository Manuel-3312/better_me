class Training {
  final int? idTraining;
  final int idProfile;
  final String name;
  final String objective;
  final int maxDays;
  final double maxTime;

  Training({
    this.idTraining,
    required this.idProfile,
    required this.name,
    required this.objective,
    required this.maxDays,
    required this.maxTime,
  });
}
