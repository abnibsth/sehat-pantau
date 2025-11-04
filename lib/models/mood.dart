class MoodEntry {
  final DateTime date;
  final int mood; // -2 sangat buruk, -1 buruk, 0 netral, 1 baik, 2 sangat baik
  final String? note;
  final double? temperatureC;
  final int? weatherCode;

  MoodEntry({
    required this.date,
    required this.mood,
    this.note,
    this.temperatureC,
    this.weatherCode,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'mood': mood,
        'note': note,
        'temperatureC': temperatureC,
        'weatherCode': weatherCode,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        date: DateTime.parse(json['date'] as String),
        mood: json['mood'] as int,
        note: json['note'] as String?,
        temperatureC: (json['temperatureC'] as num?)?.toDouble(),
        weatherCode: json['weatherCode'] as int?,
      );
}


