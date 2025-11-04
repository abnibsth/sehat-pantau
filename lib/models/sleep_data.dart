class SleepData {
  final String? id; // ID dari database
  final DateTime date;
  final DateTime bedTime;
  final DateTime wakeTime;
  final Duration totalSleep;
  final int sleepQuality; // 1-5 rating
  final String notes;

  SleepData({
    this.id,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.totalSleep,
    required this.sleepQuality,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'totalSleep': totalSleep.inMinutes,
      'sleepQuality': sleepQuality,
      'notes': notes,
    };
  }

  factory SleepData.fromJson(Map<String, dynamic> json) {
    // Handle both database format and local format
    if (json['date'] is String) {
      // Format dari database (date sebagai DATE)
      return SleepData(
        id: json['id'],
        date: DateTime.parse(json['date']),
        bedTime: DateTime.parse(json['bed_time']),
        wakeTime: DateTime.parse(json['wake_time']),
        totalSleep: Duration(minutes: json['total_sleep_minutes'] ?? json['totalSleep']),
        sleepQuality: json['sleep_quality'] ?? json['sleepQuality'],
        notes: json['notes'] ?? '',
      );
    } else {
      // Format lama (untuk backward compatibility)
      return SleepData(
        id: json['id'],
        date: DateTime.parse(json['date']),
        bedTime: DateTime.parse(json['bedTime']),
        wakeTime: DateTime.parse(json['wakeTime']),
        totalSleep: Duration(minutes: json['totalSleep']),
        sleepQuality: json['sleepQuality'],
        notes: json['notes'] ?? '',
      );
    }
  }
}
