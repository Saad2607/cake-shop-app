class Celebration {
  final String id;
  final String personName;
  final String occasionType; // Birthday, Anniversary, Graduation, Festival, Other
  final DateTime date;
  final int reminderDaysBefore;
  final String? notes;
  final String? cakePreference;

  const Celebration({
    required this.id,
    required this.personName,
    required this.occasionType,
    required this.date,
    this.reminderDaysBefore = 3,
    this.notes,
    this.cakePreference,
  });

  /// Calculates days until the next occurrence this year (or next year if passed)
  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(today.year, date.month, date.day);

    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }

    return next.difference(today).inDays;
  }

  bool get isToday => daysUntilNext == 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'personName': personName,
        'occasionType': occasionType,
        'date': date.toIso8601String(),
        'reminderDaysBefore': reminderDaysBefore,
        'notes': notes,
        'cakePreference': cakePreference,
      };

  factory Celebration.fromJson(Map<String, dynamic> json) => Celebration(
        id: (json['id'] ?? json['_id'])?.toString() ?? '',
        personName: json['personName'] as String? ?? 'Loved One',
        occasionType: json['occasionType'] as String? ?? 'Birthday',
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 3,
        notes: json['notes'] as String?,
        cakePreference: json['cakePreference'] as String?,
      );
}
