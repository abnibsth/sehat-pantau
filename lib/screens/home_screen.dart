import 'package:flutter/material.dart';
import '../services/step_service.dart';
import '../services/sleep_service.dart';
import '../services/food_service.dart';
import '../services/insight_service.dart';
import '../services/smart_reminder_service.dart';
import '../services/activity_monitor_service.dart';
import '../widgets/health_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/smart_reminder_widget.dart';
import 'steps_screen.dart';
import 'sleep_screen.dart';
import 'nutrition_screen.dart';
import 'food_list_screen.dart';
import 'weekly_summary_screen.dart';
import 'gamification_screen.dart';
import 'smart_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final StepService _stepService = StepService();
  final SleepService _sleepService = SleepService();
  final FoodService _foodService = FoodService();
  final InsightService _insightService = InsightService();
  final SmartReminderService _reminderService = SmartReminderService();
  final ActivityMonitorService _monitorService = ActivityMonitorService();

  int _currentSteps = 0;
  double _averageSleepHours = 0.0;
  double _dailyCalories = 0.0;
  int _dailyFoodCount = 0;
  List<HealthInsight> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startActivityMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
      // Check reminders ketika app kembali aktif
      _monitorService.checkNow();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _stepService.initialize();
      final stepHistory = await _stepService.getStepHistory(1);
      final sleepHistory = await _sleepService.getSleepHistory(7);
      final foodHistory = await _foodService.getFoodHistory(1);
      final todayFood = await _foodService.getFoodHistoryForDate(DateTime.now());

      final insights = _insightService.generateInsights(
        stepHistory: stepHistory,
        sleepHistory: sleepHistory,
        foodHistory: foodHistory,
      );

      setState(() {
        _currentSteps = _stepService.currentSteps;
        _averageSleepHours = _sleepService.getAverageSleepHours(sleepHistory);
        _dailyCalories = _foodService.getDailyNutrition(todayFood)['calories'] ?? 0.0;
        _dailyFoodCount = todayFood.length;
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startActivityMonitoring() async {
    try {
      await _monitorService.startMonitoring();
    } catch (e) {
      print('Error starting activity monitoring: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Sehat dan Pantau',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
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
                            'Selamat Datang! 👋',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pantau kesehatan Anda hari ini',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Health Cards
                    const Text(
                      'Dashboard Kesehatan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Steps Card
                    HealthCard(
                      title: 'Langkah',
                      value: '$_currentSteps',
                      subtitle: 'langkah',
                      icon: Icons.directions_walk,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StepsScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Sleep Card
                    HealthCard(
                      title: 'Tidur',
                      value: '${_averageSleepHours.toStringAsFixed(1)}',
                      subtitle: 'jam',
                      icon: Icons.bedtime,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SleepScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Calories Card
                    HealthCard(
                      title: 'Kalori',
                      value: '${_dailyCalories.toInt()}',
                      subtitle: 'kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NutritionScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Food Card
                    HealthCard(
                      title: 'Makanan',
                      value: '$_dailyFoodCount',
                      subtitle: 'item',
                      icon: Icons.restaurant,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FoodListScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Insights Section
                    if (_insights.isNotEmpty) ...[
                      InsightList(insights: _insights),
                      const SizedBox(height: 24),
                    ],
                    
                    // Smart Reminders Section
                    const SmartReminderWidget(),
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            'Ringkasan Mingguan',
                            Icons.trending_up,
                            Colors.blue,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WeeklySummaryScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            'Gamifikasi',
                            Icons.emoji_events,
                            Colors.purple,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GamificationScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Activity Tracking
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            'Minum Air',
                            Icons.water_drop,
                            Colors.blue,
                            () async {
                              await _monitorService.trackWater();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Aktivitas minum air dicatat!'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            'Istirahat',
                            Icons.coffee,
                            Colors.orange,
                            () async {
                              await _monitorService.trackBreak();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Waktunya istirahat!'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}