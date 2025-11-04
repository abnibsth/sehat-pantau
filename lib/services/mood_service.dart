import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood.dart';
import '../services/weather_service.dart';
import 'supabase_service.dart';

class MoodService {
  static const String _key = 'mood_entries_v1';
  final _supabase = SupabaseService.client;

  Future<List<MoodEntry>> getAll() async {
    try {
      final userId = SupabaseService().currentUserId;
      if (userId != null) {
        // Ambil dari Supabase
        final response = await _supabase
            .from('mood_entries')
            .select()
            .eq('user_id', userId)
            .order('date', ascending: false);
        
        if (response.isNotEmpty) {
          return response.map((json) => MoodEntry.fromJson({
            'date': json['date'],
            'mood': json['mood'],
            'note': json['note'],
            'temperatureC': json['temperature_c'],
            'weatherCode': json['weather_code'],
          })).toList();
        }
      }
    } catch (e) {
      print('Error getting mood entries from Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List list = json.decode(raw) as List;
    return list.map((e) => MoodEntry.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> addMood({required int mood, String? note}) async {
    try {
      final userId = SupabaseService().currentUserId;
      if (userId != null) {
        // Snapshot cuaca saat ini (best-effort)
        double? temp;
        int? code;
        try {
          final w = await WeatherService().fetchWeather();
          temp = w.temperatureC;
          code = w.weatherCode;
        } catch (_) {}

        final date = DateTime.now();
        final dateStr = date.toIso8601String().split('T')[0];
        
        // Simpan ke Supabase
        await _supabase.from('mood_entries').upsert({
          'user_id': userId,
          'date': dateStr,
          'mood': mood,
          'note': note,
          'temperature_c': temp,
          'weather_code': code,
        }, onConflict: 'user_id,date');
        
        return;
      }
    } catch (e) {
      print('Error saving mood entry to Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
    final entries = await getAll();
    double? temp;
    int? code;
    try {
      final w = await WeatherService().fetchWeather();
      temp = w.temperatureC;
      code = w.weatherCode;
    } catch (_) {}

    final entry = MoodEntry(
      date: DateTime.now(),
      mood: mood,
      note: note,
      temperatureC: temp,
      weatherCode: code,
    );
    entries.add(entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(entries.map((e) => e.toJson()).toList()));
  }
}


