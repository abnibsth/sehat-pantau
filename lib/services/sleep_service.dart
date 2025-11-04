import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sleep_data.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class SleepService {
  static final SleepService _instance = SleepService._internal();
  factory SleepService() => _instance;
  SleepService._internal();

  final String _sleepHistoryKey = 'sleep_history';
  final _supabase = SupabaseService.client;
  final _uuid = const Uuid();

  Future<void> saveSleepData(SleepData sleepData) async {
    try {
      SupabaseService().ensureAuthenticated();
      final userId = SupabaseService().currentUserId;
      if (userId == null) throw Exception('User tidak login');
      
      // Simpan ke Supabase
      await _supabase.from('sleep_data').upsert({
        if (sleepData.id != null) 'id': sleepData.id,
        'user_id': userId,
        'date': sleepData.date.toIso8601String().split('T')[0], // Format DATE
        'bed_time': sleepData.bedTime.toIso8601String(),
        'wake_time': sleepData.wakeTime.toIso8601String(),
        'total_sleep_minutes': sleepData.totalSleep.inMinutes,
        'sleep_quality': sleepData.sleepQuality,
        'notes': sleepData.notes,
      }, onConflict: 'user_id,date');
      
      print('Sleep data saved to Supabase'); // Debug log
    } catch (e) {
      print('Error saving sleep data to Supabase: $e');
      // Fallback ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final dateKey = '${sleepData.date.year}-${sleepData.date.month.toString().padLeft(2, '0')}-${sleepData.date.day.toString().padLeft(2, '0')}';
      final historyKey = '${_sleepHistoryKey}_$dateKey';
      await prefs.setString(historyKey, jsonEncode(sleepData.toJson()));
    }
  }

  Future<List<SleepData>> getSleepHistory(int days) async {
    try {
      SupabaseService().ensureAuthenticated();
      final userId = SupabaseService().currentUserId;
      if (userId == null) throw Exception('User tidak login');
      
      final startDate = DateTime.now().subtract(Duration(days: days));
      
      // Ambil dari Supabase
      final response = await _supabase
          .from('sleep_data')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .order('date', ascending: false);
      
      if (response.isNotEmpty) {
        return response.map((json) => SleepData.fromJson({
          'id': json['id'],
          'date': json['date'],
          'bed_time': json['bed_time'],
          'wake_time': json['wake_time'],
          'total_sleep_minutes': json['total_sleep_minutes'],
          'sleep_quality': json['sleep_quality'],
          'notes': json['notes'] ?? '',
        })).toList();
      }
    } catch (e) {
      print('Error getting sleep history from Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final List<SleepData> history = [];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final historyKey = '${_sleepHistoryKey}_$dateKey';
      final sleepDataString = prefs.getString(historyKey);
      
      if (sleepDataString != null) {
        final sleepDataJson = jsonDecode(sleepDataString);
        history.add(SleepData.fromJson(sleepDataJson));
      }
    }
    
    return history;
  }

  Future<SleepData?> getSleepDataForDate(DateTime date) async {
    try {
      SupabaseService().ensureAuthenticated();
      final userId = SupabaseService().currentUserId;
      if (userId == null) throw Exception('User tidak login');
      
      final dateStr = date.toIso8601String().split('T')[0];
      
      // Ambil dari Supabase
      final response = await _supabase
          .from('sleep_data')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();
      
      if (response != null) {
        return SleepData.fromJson({
          'id': response['id'],
          'date': response['date'],
          'bed_time': response['bed_time'],
          'wake_time': response['wake_time'],
          'total_sleep_minutes': response['total_sleep_minutes'],
          'sleep_quality': response['sleep_quality'],
          'notes': response['notes'] ?? '',
        });
      }
    } catch (e) {
      print('Error getting sleep data from Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
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
