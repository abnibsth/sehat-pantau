import 'package:flutter/material.dart';
import '../services/step_service.dart';
import '../services/sleep_service.dart';
import '../services/food_service.dart';
import '../services/trend_service.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/trend_card.dart';

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  final StepService _stepService = StepService();
  final SleepService _sleepService = SleepService();
  final FoodService _foodService = FoodService();
  final TrendService _trendService = TrendService();
  
  List<Map<String, dynamic>> _chartData = [];
  WeeklyTrend? _stepTrend;
  WeeklyTrend? _sleepTrend;
  WeeklyTrend? _calorieTrend;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load data for the past 7 days
      final stepHistory = await _stepService.getStepHistory(14); // Get 14 days to calculate trends
      final sleepHistory = await _sleepService.getSleepHistory(14);
      final foodHistory = await _foodService.getFoodHistory(14);

      // Calculate trends
      final stepTrend = _trendService.calculateStepTrend(stepHistory);
      final sleepTrend = _trendService.calculateSleepTrend(sleepHistory);
      final calorieTrend = _trendService.calculateCalorieTrend(foodHistory);

      // Get chart data for the past 7 days
      final chartData = _trendService.getWeeklyChartData(
        stepHistory: stepHistory,
        sleepHistory: sleepHistory,
        foodHistory: foodHistory,
      );

      setState(() {
        _stepTrend = stepTrend;
        _sleepTrend = sleepTrend;
        _calorieTrend = calorieTrend;
        _chartData = chartData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ringkasan Mingguan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadWeeklyData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan motivasi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progres Mingguan 📈',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Lihat bagaimana performa kesehatan Anda minggu ini!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tren Cards
                    const Text(
                      'Tren & Perubahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_stepTrend != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TrendCard(trend: _stepTrend!),
                      ),
                    
                    if (_sleepTrend != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TrendCard(trend: _sleepTrend!),
                      ),
                    
                    if (_calorieTrend != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: TrendCard(trend: _calorieTrend!),
                      ),
                    
                    // Grafik Mingguan
                    const Text(
                      'Grafik Mingguan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Grafik Langkah
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: WeeklyChart(
                        chartData: _chartData,
                        title: 'Langkah Mingguan',
                        dataType: 'steps',
                        color: Colors.blue,
                      ),
                    ),
                    
                    // Grafik Tidur
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: WeeklyChart(
                        chartData: _chartData,
                        title: 'Tidur Mingguan',
                        dataType: 'sleep',
                        color: Colors.purple,
                      ),
                    ),
                    
                    // Grafik Kalori
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: WeeklyChart(
                        chartData: _chartData,
                        title: 'Kalori Mingguan',
                        dataType: 'calories',
                        color: Colors.orange,
                      ),
                    ),
                    
                    // Motivasi Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Terus Pertahankan!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Konsistensi adalah kunci untuk kesehatan yang optimal. Terus pantau progres Anda setiap minggu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
