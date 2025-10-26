import 'package:flutter/material.dart';
import '../services/food_service.dart';
import '../services/activity_monitor_service.dart';
import '../models/food_data.dart';
import '../widgets/nutrition_chart.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final FoodService _foodService = FoodService();
  final ActivityMonitorService _monitorService = ActivityMonitorService();
  List<FoodData> _todayFood = [];
  Map<String, double> _dailyNutrition = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final today = DateTime.now();
    final todayFood = await _foodService.getFoodHistoryForDate(today);
    final nutrition = _foodService.getDailyNutrition(todayFood);
    
    setState(() {
      _todayFood = todayFood;
      _dailyNutrition = nutrition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Asupan Makanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add food button
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catat Makanan Anda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddFoodDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Makanan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Daily nutrition summary
              if (_dailyNutrition.isNotEmpty) ...[
                const Text(
                  'Ringkasan Nutrisi Hari Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionCard(
                        'Kalori',
                        '${_dailyNutrition['calories']?.toInt() ?? 0}',
                        'kcal',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNutritionCard(
                        'Protein',
                        '${_dailyNutrition['protein']?.toStringAsFixed(1) ?? '0'}',
                        'g',
                        Icons.fitness_center,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionCard(
                        'Karbohidrat',
                        '${_dailyNutrition['carbs']?.toStringAsFixed(1) ?? '0'}',
                        'g',
                        Icons.grain,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNutritionCard(
                        'Lemak',
                        '${_dailyNutrition['fat']?.toStringAsFixed(1) ?? '0'}',
                        'g',
                        Icons.opacity,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Nutrition chart
                NutritionChart(
                  nutrition: _dailyNutrition,
                  title: 'Komposisi Nutrisi',
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Today's food list
              const Text(
                'Makanan Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_todayFood.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Belum ada makanan yang dicatat',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ..._todayFood.map((food) => _buildFoodItem(food)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(FoodData food) {
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
            Icons.restaurant,
            color: Colors.green[600],
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${food.quantity} ${food.unit} • ${food.mealType}'),
            Text('${food.calories.toInt()} kcal • ${food.protein.toStringAsFixed(1)}g protein'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${food.dateTime.hour.toString().padLeft(2, '0')}:${food.dateTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            IconButton(
              onPressed: () => _deleteFood(food.id),
              icon: const Icon(Icons.delete, color: Colors.red),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog() {
    String selectedFood = '';
    double quantity = 1.0;
    String mealType = 'breakfast';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Makanan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Makanan',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedFood.isEmpty ? null : selectedFood,
                  items: FoodService.foodDatabase.map<DropdownMenuItem<String>>((food) {
                    return DropdownMenuItem<String>(
                      value: food['name'] as String,
                      child: Text(food['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFood = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '1.0',
                  onChanged: (value) {
                    quantity = double.tryParse(value) ?? 1.0;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Jenis Makanan',
                    border: OutlineInputBorder(),
                  ),
                  value: mealType,
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('Sarapan')),
                    DropdownMenuItem(value: 'lunch', child: Text('Makan Siang')),
                    DropdownMenuItem(value: 'dinner', child: Text('Makan Malam')),
                    DropdownMenuItem(value: 'snack', child: Text('Cemilan')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      mealType = value ?? 'breakfast';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: selectedFood.isNotEmpty ? () => _saveFood(selectedFood, quantity, mealType) : null,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveFood(String foodName, double quantity, String mealType) async {
    final foodData = FoodService.foodDatabase.firstWhere(
      (food) => food['name'] == foodName,
    );
    
    final food = FoodData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: foodName,
      calories: foodData['calories'] * quantity,
      protein: foodData['protein'] * quantity,
      carbs: foodData['carbs'] * quantity,
      fat: foodData['fat'] * quantity,
      fiber: foodData['fiber'] * quantity,
      mealType: mealType,
      dateTime: DateTime.now(),
      quantity: quantity,
      unit: foodData['unit'],
    );
    
    await _foodService.saveFoodData(food);
    // Track meal activity
    await _monitorService.trackMeal();
    Navigator.pop(context);
    _loadData();
  }

  Future<void> _deleteFood(String foodId) async {
    await _foodService.deleteFoodData(foodId);
    _loadData();
  }
}
