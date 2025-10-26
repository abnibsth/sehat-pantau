class SleepData {
  final DateTime date;
  final DateTime bedTime;
  final DateTime wakeTime;
  final Duration totalSleep;
  final int sleepQuality; // 1-5 rating
  final String notes;

  SleepData({
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.totalSleep,
    required this.sleepQuality,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'totalSleep': totalSleep.inMinutes,
      'sleepQuality': sleepQuality,
      'notes': notes,
    };
  }

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      date: DateTime.parse(json['date']),
      bedTime: DateTime.parse(json['bedTime']),
      wakeTime: DateTime.parse(json['wakeTime']),
      totalSleep: Duration(minutes: json['totalSleep']),
      sleepQuality: json['sleepQuality'],
      notes: json['notes'] ?? '',
    );
  }
}
