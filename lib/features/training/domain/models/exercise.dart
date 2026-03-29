class Exercise {
  final int? idExercise;
  final String name;
  final String duration;
  final int sets;
  final String reps;
  final String rest;

  Exercise({
    this.idExercise,
    required this.name,
    required this.duration,
    required this.sets,
    required this.reps,
    required this.rest,
  });
}
