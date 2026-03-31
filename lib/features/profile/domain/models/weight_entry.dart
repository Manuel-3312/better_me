/// Represents a single weight measurement at a specific point in time.
class WeightEntry {
  final int? id;
  final int idProfile;
  final double weight;
  final DateTime date;

  const WeightEntry({
    this.id,
    required this.idProfile,
    required this.weight,
    required this.date,
  });

  /// Converts a Map from SQLite into a [WeightEntry] instance.
  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id_weight'] as int?,
      idProfile: map['id_profile'] as int,
      weight: map['weight'] as double,
      date: DateTime.parse(map['date']),
    );
  }

  /// Converts the [WeightEntry] into a Map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'id_weight': id,
      'id_profile': idProfile,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }
}