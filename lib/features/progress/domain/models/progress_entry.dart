import 'dart:convert';

/// Represents a user's progress log entry containing biometrics and visual tracking data.
class ProgressEntry {
  final int? id;
  final int idProfile;
  final DateTime date;
  final double weight;
  final List<String> photoPaths;

  const ProgressEntry({
    this.id,
    required this.idProfile,
    required this.date,
    required this.weight,
    required this.photoPaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_profile': idProfile,
      'entry_date': date.toIso8601String(),
      'weight': weight,
      'photo_paths': jsonEncode(photoPaths),
    };
  }

  factory ProgressEntry.fromMap(Map<String, dynamic> map) {
    return ProgressEntry(
      id: map['id'] as int?,
      idProfile: map['id_profile'] as int,
      date: DateTime.parse(map['entry_date'] as String),
      weight: (map['weight'] as num).toDouble(),
      photoPaths: List<String>.from(jsonDecode(map['photo_paths'] as String)),
    );
  }
}