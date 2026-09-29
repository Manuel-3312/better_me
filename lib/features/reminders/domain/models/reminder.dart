/// Represents a user-scheduled reminder for supplements or daily tasks.
class Reminder {
  final String id;
  final String title;
  final String? description;
  final int hour;
  final int minute;
  final bool isEnabled;

  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    int? hour,
    int? minute,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      hour: (json['hour'] as num?)?.toInt() ?? 0,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      isEnabled: json['isEnabled'] == true || json['isEnabled'] == 1 || json['isEnabled'] == '1',
    );
  }
}