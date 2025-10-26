import 'package:flutter/material.dart';
import '../services/food_service.dart';
import '../models/food_data.dart';

class IntakeScreen extends StatefulWidget {
  const IntakeScreen({super.key});

  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen> {
  final FoodService _foodService = FoodService();
  List<FoodData> _todayFood = [];
  String _selectedMealType = 'breakfast';
  final Map<String, String> _mealTypeLabels = {
    'breakfast': 'Sarapan',
    'lunch': 'Makan Siang',
    'dinner': 'Makan Malam',
    'snack': 'Camilan',
  };

  @override
  void initState() {
    super.initState();
    _loadTodayFood();
  }

  Future<void> _loadTodayFood() async {
    final today = DateTime.now();
    final food = await _foodService.getFoodHistoryForDate(today);
    setState(() {
      _todayFood = food;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Asupan Harian',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Meal type selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Jenis Makanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _mealTypeLabels.entries.map((entry) {
                      final isSelected = _selectedMealType == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedMealType = entry.key;
                            });
                          },
                          selectedColor: Colors.green[100],
                          checkmarkColor: Colors.green[700],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.green[700] : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Food database
          Expanded(
            child: _buildFoodDatabase(),
          ),
          
          // Today's intake summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Kalori',
                        '${_getTotalCalories().toInt()}',
                        'kcal',
                        Colors.orange,
                        Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Makanan',
                        '${_todayFood.length}',
                        'item',
                        Colors.green,
                        Icons.restaurant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDatabase() {
    // Show all foods from database (no filtering by mealType since database doesn't have that field)
    final allFoods = FoodService.foodDatabase;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allFoods.length,
      itemBuilder: (context, index) {
        final food = allFoods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(
                _getMealIcon(_selectedMealType),
                color: Colors.green[600],
              ),
            ),
            title: Text(
              food['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${food['calories']} kcal • ${food['protein']}g protein'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildNutritionChip('${food['carbs']}g carbs', Colors.orange),
                    const SizedBox(width: 4),
                    _buildNutritionChip('${food['fat']}g fat', Colors.blue),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _addFoodToIntake(food),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Tambah'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  double _getTotalCalories() {
    return _todayFood.fold(0.0, (sum, food) => sum + food.calories);
  }

  Future<void> _addFoodToIntake(Map<String, dynamic> foodData) async {
    try {
      final now = DateTime.now();
      final food = FoodData(
        id: '${now.millisecondsSinceEpoch}_${foodData['name']}',
        name: foodData['name'],
        calories: foodData['calories'].toDouble(),
        protein: foodData['protein'].toDouble(),
        carbs: foodData['carbs'].toDouble(),
        fat: foodData['fat'].toDouble(),
        fiber: foodData['fiber'].toDouble(),
        mealType: _selectedMealType,
        dateTime: now,
        quantity: 1.0, // Default quantity
        unit: foodData['unit'] ?? 'porsi', // Use unit from database or default
      );

      await _foodService.saveFoodData(food);
      await _loadTodayFood();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${foodData['name']} berhasil ditambahkan ke ${_mealTypeLabels[_selectedMealType]}'),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error menambahkan makanan: $e'),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
