import 'package:flutter/material.dart';
import '../services/food_service.dart';
import '../widgets/nutrition_chart.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final FoodService _foodService = FoodService();
  Map<String, double> _dailyNutritionSummary = {};

  @override
  void initState() {
    super.initState();
    _initializeNutritionData();
  }

  Future<void> _initializeNutritionData() async {
    await _loadDailyNutritionData();
  }

  Future<void> _loadDailyNutritionData() async {
    final today = DateTime.now();
    final history = await _foodService.getFoodHistoryForDate(today);
    setState(() {
      _dailyNutritionSummary = _foodService.getDailyNutrition(history);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Analisis Nutrisi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDailyNutritionData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Nutrisi Harian
              const Text(
                'Ringkasan Nutrisi Harian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Cards untuk nutrisi utama
              Row(
                children: [
                  Expanded(
                    child: _buildNutritionCard(
                      'Kalori',
                      '${_dailyNutritionSummary['calories']?.toInt() ?? 0}',
                      'kcal',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNutritionCard(
                      'Protein',
                      '${_dailyNutritionSummary['protein']?.toInt() ?? 0}',
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
                      '${_dailyNutritionSummary['carbs']?.toInt() ?? 0}',
                      'g',
                      Icons.rice_bowl,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNutritionCard(
                      'Lemak',
                      '${_dailyNutritionSummary['fat']?.toInt() ?? 0}',
                      'g',
                      Icons.fastfood,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Komposisi Nutrisi Chart
              const Text(
                'Komposisi Nutrisi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _dailyNutritionSummary.isNotEmpty && _dailyNutritionSummary.values.any((e) => e > 0)
                      ? NutritionChart(
                          nutrition: _dailyNutritionSummary,
                          title: 'Komposisi Nutrisi Harian',
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'Belum ada data nutrisi untuk ditampilkan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Target Kalori Harian
              const Text(
                'Target Kalori Harian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Target: 2000 kcal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Tersisa: ${(2000 - (_dailyNutritionSummary['calories'] ?? 0)).toInt()} kcal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (_dailyNutritionSummary['calories'] ?? 0) / 2000,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (_dailyNutritionSummary['calories'] ?? 0) >= 2000 
                            ? Colors.green 
                            : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((_dailyNutritionSummary['calories'] ?? 0) / 2000 * 100).toInt()}% dari target harian',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$title ($unit)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
