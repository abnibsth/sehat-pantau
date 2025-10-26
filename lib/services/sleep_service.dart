import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sleep_data.dart';

class SleepService {
  static final SleepService _instance = SleepService._internal();
  factory SleepService() => _instance;
  SleepService._internal();

  final String _sleepHistoryKey = 'sleep_history';

  Future<void> saveSleepData(SleepData sleepData) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '${sleepData.date.year}-${sleepData.date.month.toString().padLeft(2, '0')}-${sleepData.date.day.toString().padLeft(2, '0')}';
    final historyKey = '${_sleepHistoryKey}_$dateKey';
    await prefs.setString(historyKey, jsonEncode(sleepData.toJson()));
    print('Sleep data saved with key: $historyKey'); // Debug log
  }

  Future<List<SleepData>> getSleepHistory(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final List<SleepData> history = [];
    final now = DateTime.now();
    
    print('Getting sleep history for $days days'); // Debug log
    
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final historyKey = '${_sleepHistoryKey}_$dateKey';
      final sleepDataString = prefs.getString(historyKey);
      
      print('Checking key: $historyKey, found: ${sleepDataString != null}'); // Debug log
      
      if (sleepDataString != null) {
        final sleepDataJson = jsonDecode(sleepDataString);
        history.add(SleepData.fromJson(sleepDataJson));
      }
    }
    
    print('Found ${history.length} sleep records'); // Debug log
    return history;
  }

  Future<SleepData?> getSleepDataForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final historyKey = '${_sleepHistoryKey}_$dateKey';
    final sleepDataString = prefs.getString(historyKey);
    
    if (sleepDataString != null) {
      final sleepDataJson = jsonDecode(sleepDataString);
      return SleepData.fromJson(sleepDataJson);
    }
    
    return null;
  }

  Future<void> deleteSleepData(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final historyKey = '${_sleepHistoryKey}_$dateKey';
    await prefs.remove(historyKey);
  }

  double getAverageSleepHours(List<SleepData> sleepHistory) {
    if (sleepHistory.isEmpty) return 0.0;
    
    final totalMinutes = sleepHistory
        .map((data) => data.totalSleep.inMinutes)
        .reduce((a, b) => a + b);
    
    return totalMinutes / sleepHistory.length / 60.0;
  }

  double getAverageSleepQuality(List<SleepData> sleepHistory) {
    if (sleepHistory.isEmpty) return 0.0;
    
    final totalQuality = sleepHistory
        .map((data) => data.sleepQuality)
        .reduce((a, b) => a + b);
    
    return totalQuality / sleepHistory.length;
  }
}
