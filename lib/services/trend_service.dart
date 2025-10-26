import '../models/step_data.dart';
import '../models/sleep_data.dart';
import '../models/food_data.dart';

class WeeklyTrend {
  final String title;
  final double currentWeek;
  final double previousWeek;
  final double percentageChange;
  final String trend; // 'up', 'down', 'stable'
  final String description;

  WeeklyTrend({
    required this.title,
    required this.currentWeek,
    required this.previousWeek,
    required this.percentageChange,
    required this.trend,
    required this.description,
  });
}

class TrendService {
  static final TrendService _instance = TrendService._internal();
  factory TrendService() => _instance;
  TrendService._internal();

  // Hitung tren langkah mingguan
  WeeklyTrend calculateStepTrend(List<StepData> stepHistory) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = currentWeekStart.subtract(const Duration(days: 1));

    // Data minggu ini
    final currentWeekData = stepHistory.where((data) {
      final dataDate = data.date;
      return dataDate.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
             dataDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    // Data minggu lalu
    final previousWeekData = stepHistory.where((data) {
      final dataDate = data.date;
      return dataDate.isAfter(previousWeekStart.subtract(const Duration(days: 1))) &&
             dataDate.isBefore(previousWeekEnd.add(const Duration(days: 1)));
    }).toList();

    final currentWeekAvg = currentWeekData.isNotEmpty 
        ? currentWeekData.map((e) => e.steps).reduce((a, b) => a + b) / currentWeekData.length
        : 0.0;
    
    final previousWeekAvg = previousWeekData.isNotEmpty
        ? previousWeekData.map((e) => e.steps).reduce((a, b) => a + b) / previousWeekData.length
        : 0.0;

    final percentageChange = previousWeekAvg > 0 
        ? ((currentWeekAvg - previousWeekAvg) / previousWeekAvg * 100)
        : 0.0;

    String trend;
    String description;
    
    if (percentageChange > 5) {
      trend = 'up';
      description = 'Langkah meningkat ${percentageChange.abs().toStringAsFixed(1)}% dibanding minggu lalu';
    } else if (percentageChange < -5) {
      trend = 'down';
      description = 'Langkah menurun ${percentageChange.abs().toStringAsFixed(1)}% dibanding minggu lalu';
    } else {
      trend = 'stable';
      description = 'Langkah stabil dibanding minggu lalu';
    }

    return WeeklyTrend(
      title: 'Langkah Mingguan',
      currentWeek: currentWeekAvg,
      previousWeek: previousWeekAvg,
      percentageChange: percentageChange,
      trend: trend,
      description: description,
    );
  }

  // Hitung tren tidur mingguan
  WeeklyTrend calculateSleepTrend(List<SleepData> sleepHistory) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = currentWeekStart.subtract(const Duration(days: 1));

    // Data minggu ini
    final currentWeekData = sleepHistory.where((data) {
      final dataDate = data.date;
      return dataDate.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
             dataDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    // Data minggu lalu
    final previousWeekData = sleepHistory.where((data) {
      final dataDate = data.date;
      return dataDate.isAfter(previousWeekStart.subtract(const Duration(days: 1))) &&
             dataDate.isBefore(previousWeekEnd.add(const Duration(days: 1)));
    }).toList();

    final currentWeekAvg = currentWeekData.isNotEmpty 
        ? currentWeekData.map((e) => e.totalSleep.inHours).reduce((a, b) => a + b) / currentWeekData.length
        : 0.0;
    
    final previousWeekAvg = previousWeekData.isNotEmpty
        ? previousWeekData.map((e) => e.totalSleep.inHours).reduce((a, b) => a + b) / previousWeekData.length
        : 0.0;

    final percentageChange = previousWeekAvg > 0 
        ? ((currentWeekAvg - previousWeekAvg) / previousWeekAvg * 100)
        : 0.0;

    String trend;
    String description;
    
    if (percentageChange > 5) {
      trend = 'up';
      description = 'Tidur meningkat ${percentageChange.abs().toStringAsFixed(1)}% dibanding minggu lalu';
    } else if (percentageChange < -5) {
      trend = 'down';
      description = 'Tidur menurun ${percentageChange.abs().toStringAsFixed(1)}% dibanding minggu lalu';
    } else {
      trend = 'stable';
      description = 'Tidur stabil dibanding minggu lalu';
    }

    return WeeklyTrend(
      title: 'Tidur Mingguan',
      currentWeek: currentWeekAvg,
      previousWeek: previousWeekAvg,
      percentageChange: percentageChange,
      trend: trend,
      description: description,
    );
  }

  // Hitung tren kalori mingguan
  WeeklyTrend calculateCalorieTrend(List<FoodData> foodHistory) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = currentWeekStart.subtract(const Duration(days: 1));

    // Data minggu ini
    final currentWeekData = foodHistory.where((data) {
      final dataDate = data.dateTime;
      return dataDate.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
             dataDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    // Data minggu lalu
    final previousWeekData = foodHistory.where((data) {
      final dataDate = data.dateTime;
      return dataDate.isAfter(previousWeekStart.subtract(const Duration(days: 1))) &&
             dataDate.isBefore(previousWeekEnd.add(const Duration(days: 1)));
    }).toList();

    final currentWeekAvg = currentWeekData.isNotEmpty 
        ? currentWeekData.map((e) => e.calories).reduce((a, b) => a + b) / currentWeekData.length
        : 0.0;
    
    final previousWeekAvg = previousWeekData.isNotEmpty
        ? previousWeekData.map((e) => e.calories).reduce((a, b) => a + b) / previousWeekData.length
        : 0.0;

    final percentageChange = previousWeekAvg > 0 
        ? ((currentWeekAvg - previousWeekAvg) / previousWeekAvg * 100)
        : 0.0;

    String trend;
    String description;
    
    if (percentageChange > 5) {
      trend = 'up';
      description = 'Kalori meningkat ${percentageChange.abs().toStringAsFixed(1)}% dibanding minggu lalu';
    } else if (percentageChange < -5) {
      trend = 'down';
      description = 'Kalori menurun ${percentageChange.abs().toStringAsFixed(1)}% dibanding minggu lalu';
    } else {
      trend = 'stable';
      description = 'Kalori stabil dibanding minggu lalu';
    }

    return WeeklyTrend(
      title: 'Kalori Mingguan',
      currentWeek: currentWeekAvg,
      previousWeek: previousWeekAvg,
      percentageChange: percentageChange,
      trend: trend,
      description: description,
    );
  }

  // Dapatkan data untuk grafik mingguan (7 hari terakhir)
  List<Map<String, dynamic>> getWeeklyChartData({
    required List<StepData> stepHistory,
    required List<SleepData> sleepHistory,
    required List<FoodData> foodHistory,
  }) {
    final List<Map<String, dynamic>> chartData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      
      // Data langkah hari ini
      final daySteps = stepHistory.where((data) => 
        data.date.year == date.year &&
        data.date.month == date.month &&
        data.date.day == date.day
      ).toList();
      
      // Data tidur hari ini
      final daySleep = sleepHistory.where((data) => 
        data.date.year == date.year &&
        data.date.month == date.month &&
        data.date.day == date.day
      ).toList();
      
      // Data kalori hari ini
      final dayFood = foodHistory.where((data) => 
        data.dateTime.year == date.year &&
        data.dateTime.month == date.month &&
        data.dateTime.day == date.day
      ).toList();

      final steps = daySteps.isNotEmpty ? daySteps.first.steps : 0;
      final sleepHours = daySleep.isNotEmpty ? daySleep.first.totalSleep.inHours : 0.0;
      final calories = dayFood.isNotEmpty 
          ? dayFood.map((e) => e.calories).reduce((a, b) => a + b) 
          : 0.0;

      chartData.add({
        'day': dayName,
        'date': date,
        'steps': steps,
        'sleep': sleepHours,
        'calories': calories,
      });
    }

    return chartData;
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }
}
