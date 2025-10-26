class FoodData {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime dateTime;
  final double quantity; // dalam gram atau porsi
  final String unit; // gram, porsi, ml, etc

  FoodData({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.mealType,
    required this.dateTime,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'mealType': mealType,
      'dateTime': dateTime.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory FoodData.fromJson(Map<String, dynamic> json) {
    return FoodData(
      id: json['id'],
      name: json['name'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
      mealType: json['mealType'],
      dateTime: DateTime.parse(json['dateTime']),
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
    );
  }
}
