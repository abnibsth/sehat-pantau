import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food_data.dart';

class FoodService {
  static final FoodService _instance = FoodService._internal();
  factory FoodService() => _instance;
  FoodService._internal();

  final String _foodHistoryKey = 'food_history';

  Future<void> saveFoodData(FoodData foodData) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = '${_foodHistoryKey}_${foodData.id}';
    await prefs.setString(historyKey, jsonEncode(foodData.toJson()));
  }

  Future<List<FoodData>> getFoodHistoryForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<FoodData> history = [];
    final keys = prefs.getKeys();
    
    for (String key in keys) {
      if (key.startsWith(_foodHistoryKey)) {
        final foodDataString = prefs.getString(key);
        if (foodDataString != null) {
          final foodDataJson = jsonDecode(foodDataString);
          final foodData = FoodData.fromJson(foodDataJson);
          
          // Filter berdasarkan tanggal
          if (foodData.dateTime.year == date.year &&
              foodData.dateTime.month == date.month &&
              foodData.dateTime.day == date.day) {
            history.add(foodData);
          }
        }
      }
    }
    
    // Sort berdasarkan waktu
    history.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return history;
  }

  Future<List<FoodData>> getFoodHistory(int days) async {
    final List<FoodData> allHistory = [];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayHistory = await getFoodHistoryForDate(date);
      allHistory.addAll(dayHistory);
    }
    
    return allHistory;
  }

  Future<void> deleteFoodData(String foodId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = '${_foodHistoryKey}_$foodId';
    await prefs.remove(historyKey);
  }

  Map<String, double> getDailyNutrition(List<FoodData> foodHistory) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (FoodData food in foodHistory) {
      totalCalories += food.calories;
      totalProtein += food.protein;
      totalCarbs += food.carbs;
      totalFat += food.fat;
      totalFiber += food.fiber;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
      'fiber': totalFiber,
    };
  }

  Map<String, double> getNutritionByMealType(List<FoodData> foodHistory) {
    Map<String, double> mealNutrition = {};
    
    for (String mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final mealFoods = foodHistory.where((food) => food.mealType == mealType).toList();
      final nutrition = getDailyNutrition(mealFoods);
      mealNutrition[mealType] = nutrition['calories'] ?? 0;
    }
    
    return mealNutrition;
  }

  // Predefined food database
  static final List<Map<String, dynamic>> foodDatabase = [
    {
      'name': 'Nasi Putih',
      'calories': 130,
      'protein': 2.7,
      'carbs': 28,
      'fat': 0.3,
      'fiber': 0.4,
      'unit': '100g'
    },
    {
      'name': 'Ayam Goreng',
      'calories': 239,
      'protein': 25.1,
      'carbs': 0,
      'fat': 14.7,
      'fiber': 0,
      'unit': '100g'
    },
    {
      'name': 'Telur Rebus',
      'calories': 155,
      'protein': 13,
      'carbs': 1.1,
      'fat': 11,
      'fiber': 0,
      'unit': '1 butir'
    },
    {
      'name': 'Pisang',
      'calories': 89,
      'protein': 1.1,
      'carbs': 23,
      'fat': 0.3,
      'fiber': 2.6,
      'unit': '1 buah'
    },
    {
      'name': 'Apel',
      'calories': 52,
      'protein': 0.3,
      'carbs': 14,
      'fat': 0.2,
      'fiber': 2.4,
      'unit': '1 buah'
    },
    {
      'name': 'Susu Sapi',
      'calories': 42,
      'protein': 3.4,
      'carbs': 5,
      'fat': 1,
      'fiber': 0,
      'unit': '100ml'
    },
  ];
}
