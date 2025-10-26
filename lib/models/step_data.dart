class StepData {
  final DateTime date;
  final int steps;
  final double distance; // dalam meter
  final int calories;

  StepData({
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'calories': calories,
    };
  }

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      date: DateTime.parse(json['date']),
      steps: json['steps'],
      distance: json['distance'].toDouble(),
      calories: json['calories'],
    );
  }
}
