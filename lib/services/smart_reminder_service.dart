import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/smart_reminder.dart';
import '../models/step_data.dart';
import '../models/sleep_data.dart';
import '../models/food_data.dart';
import '../services/weather_service.dart';
import 'supabase_service.dart';

class SmartReminderService {
  static final SmartReminderService _instance = SmartReminderService._internal();
  factory SmartReminderService() => _instance;
  SmartReminderService._internal();

  static const String _remindersKey = 'smart_reminders';
  static const String _settingsKey = 'reminder_settings';
  
  final Uuid _uuid = const Uuid();
  final _supabase = SupabaseService.client;

  // Generate smart reminders berdasarkan aktivitas pengguna
  Future<List<SmartReminder>> generateSmartReminders({
    required List<StepData> stepHistory,
    required List<SleepData> sleepHistory,
    required List<FoodData> foodHistory,
  }) async {
    final List<SmartReminder> reminders = [];
    final now = DateTime.now();
    final settings = await getReminderSettings();

    // 1. Reminder Makan - Berdasarkan waktu makan terakhir
    if (settings.enableMealReminders) {
      final mealReminder = _generateMealReminder(foodHistory, now, settings);
      if (mealReminder != null) {
        reminders.add(mealReminder);
      }
    }

    // 2. Reminder Gerakan - Berdasarkan aktivitas duduk
    if (settings.enableMovementReminders) {
      final movementReminder = _generateMovementReminder(stepHistory, now, settings);
      if (movementReminder != null) {
        reminders.add(movementReminder);
      }
    }

    // 3. Reminder Tidur - Berdasarkan pola tidur
    if (settings.enableSleepReminders) {
      final sleepReminder = _generateSleepReminder(sleepHistory, now, settings);
      if (sleepReminder != null) {
        reminders.add(sleepReminder);
      }
    }

    // 4. Reminder Minum Air - Berdasarkan waktu terakhir minum
    if (settings.enableWaterReminders) {
      final waterReminder = await _generateWaterReminder(now, settings);
      if (waterReminder != null) {
        reminders.add(waterReminder);
      }
    }

    // 5. Reminder Istirahat - Berdasarkan aktivitas berkelanjutan
    if (settings.enableBreakReminders) {
      final breakReminder = await _generateBreakReminder(stepHistory, now, settings);
      if (breakReminder != null) {
        reminders.add(breakReminder);
      }
    }

    // 6. Reminder Cuaca - Berdasarkan kondisi cuaca saat ini
    final weatherReminder = await _generateWeatherReminder(now);
    if (weatherReminder != null) {
      reminders.add(weatherReminder);
    }

    return reminders;
  }

  // Reminder berbasis cuaca
  Future<SmartReminder?> _generateWeatherReminder(DateTime now) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastKey = 'last_weather_reminder_date';
      final lastStr = prefs.getString(lastKey);
      if (lastStr != null) {
        final last = DateTime.tryParse(lastStr);
        if (last != null && last.year == now.year && last.month == now.month && last.day == now.day) {
          // Hanya sekali per hari
          return null;
        }
      }

      final weather = await WeatherService().fetchWeather();
      final code = weather.weatherCode;
      final temp = weather.temperatureC;

      String? title;
      String? message;
      ReminderPriority priority = ReminderPriority.medium;

      final isRain = {51, 53, 55, 61, 63, 65, 66, 67, 95, 96, 99}.contains(code);
      final isHot = temp >= 33;
      final isClear = code == 0 || {1, 2}.contains(code);

      if (isRain) {
        title = 'Hujan Datang 🌧️';
        message = 'Hujan sore ini, pertimbangkan olahraga di rumah.';
        priority = ReminderPriority.medium;
      } else if (isHot) {
        title = 'Cuaca Panas 🌞';
        final t = temp.toStringAsFixed(0);
        message = 'Suhu $t°C, jangan lupa minum air setiap 2 jam.';
        priority = ReminderPriority.high;
      } else if (isClear) {
        title = 'Cerah! 🌤️';
        message = 'Cuaca cerah! Waktu terbaik untuk jalan pagi.';
        priority = ReminderPriority.low;
      }

      if (title != null && message != null) {
        await prefs.setString(lastKey, DateTime(now.year, now.month, now.day).toIso8601String());
        return SmartReminder(
          id: _uuid.v4(),
          title: title,
          message: message,
          type: ReminderType.weather,
          priority: priority,
          createdAt: now,
          context: {
            'temperature_c': temp,
            'weather_code': code,
            'location': weather.locationName,
          },
        );
      }
    } catch (_) {
      // Abaikan error cuaca agar tidak mengganggu reminder lain
      return null;
    }

    return null;
  }

  // Generate reminder makan berdasarkan pola makan
  SmartReminder? _generateMealReminder(List<FoodData> foodHistory, DateTime now, ReminderSettings settings) {
    if (foodHistory.isEmpty) {
      return SmartReminder(
        id: _uuid.v4(),
        title: 'Waktunya Makan! 🍽️',
        message: 'Kamu belum makan hari ini. Yuk, isi energi dengan makanan bergizi!',
        type: ReminderType.meal,
        priority: ReminderPriority.high,
        createdAt: now,
        context: {'reason': 'no_meals_today'},
      );
    }

    // Cari makan terakhir
    final lastMeal = foodHistory
        .where((food) => food.dateTime.isBefore(now))
        .fold<FoodData?>(null, (latest, current) {
      if (latest == null) return current;
      return current.dateTime.isAfter(latest.dateTime) ? current : latest;
    });

    if (lastMeal != null) {
      final hoursSinceLastMeal = now.difference(lastMeal.dateTime).inHours;
      
      if (hoursSinceLastMeal >= settings.mealIntervalHours) {
        String message;
        ReminderPriority priority;
        
        if (hoursSinceLastMeal >= 8) {
          message = 'Kamu belum makan selama $hoursSinceLastMeal jam! Saatnya isi energi dengan makanan bergizi.';
          priority = ReminderPriority.urgent;
        } else if (hoursSinceLastMeal >= 6) {
          message = 'Sudah $hoursSinceLastMeal jam sejak makan terakhir. Waktunya makan lagi!';
          priority = ReminderPriority.high;
        } else {
          message = 'Karena kamu belum makan sejak $hoursSinceLastMeal jam lalu, saatnya isi energi!';
          priority = ReminderPriority.medium;
        }

        return SmartReminder(
          id: _uuid.v4(),
          title: 'Waktunya Makan! 🍽️',
          message: message,
          type: ReminderType.meal,
          priority: priority,
          createdAt: now,
          context: {
            'hours_since_last_meal': hoursSinceLastMeal,
            'last_meal_time': lastMeal.dateTime.toIso8601String(),
          },
        );
      }
    }

    return null;
  }

  // Generate reminder gerakan berdasarkan aktivitas
  SmartReminder? _generateMovementReminder(List<StepData> stepHistory, DateTime now, ReminderSettings settings) {
    if (stepHistory.isEmpty) {
      return SmartReminder(
        id: _uuid.v4(),
        title: 'Ayo Bergerak! 🚶‍♂️',
        message: 'Kamu belum banyak bergerak hari ini. Yuk, jalan-jalan sebentar!',
        type: ReminderType.movement,
        priority: ReminderPriority.medium,
        createdAt: now,
        context: {'reason': 'low_activity_today'},
      );
    }

    // Cek aktivitas terakhir
    final lastActivity = stepHistory
        .where((step) => step.date.isBefore(now))
        .fold<StepData?>(null, (latest, current) {
      if (latest == null) return current;
      return current.date.isAfter(latest.date) ? current : latest;
    });

    if (lastActivity != null) {
      final minutesSinceLastActivity = now.difference(lastActivity.date).inMinutes;
      
      if (minutesSinceLastActivity >= settings.movementIntervalMinutes) {
        String message;
        ReminderPriority priority;
        
        if (minutesSinceLastActivity >= 180) { // 3 jam
          message = 'Kamu sudah duduk selama ${(minutesSinceLastActivity / 60).toInt()} jam! Ayo jalan sebentar untuk kesehatan!';
          priority = ReminderPriority.high;
        } else if (minutesSinceLastActivity >= 120) { // 2 jam
          message = 'Kamu sudah duduk selama ${(minutesSinceLastActivity / 60).toInt()} jam. Saatnya bergerak!';
          priority = ReminderPriority.medium;
        } else {
          message = 'Kamu sudah duduk selama $minutesSinceLastActivity menit. Ayo jalan sebentar!';
          priority = ReminderPriority.low;
        }

        return SmartReminder(
          id: _uuid.v4(),
          title: 'Ayo Bergerak! 🚶‍♂️',
          message: message,
          type: ReminderType.movement,
          priority: priority,
          createdAt: now,
          context: {
            'minutes_since_last_activity': minutesSinceLastActivity,
            'last_activity_time': lastActivity.date.toIso8601String(),
          },
        );
      }
    }

    return null;
  }

  // Generate reminder tidur berdasarkan pola tidur
  SmartReminder? _generateSleepReminder(List<SleepData> sleepHistory, DateTime now, ReminderSettings settings) {
    final currentHour = now.hour;
    
    // Cek apakah sudah waktunya tidur (21:00 - 23:00)
    if (currentHour >= 21 && currentHour <= 23) {
      final lastSleep = sleepHistory
          .where((sleep) => sleep.date.isBefore(now))
          .fold<SleepData?>(null, (latest, current) {
        if (latest == null) return current;
        return current.date.isAfter(latest.date) ? current : latest;
      });

      if (lastSleep == null || now.difference(lastSleep.date).inDays >= 1) {
        return SmartReminder(
          id: _uuid.v4(),
          title: 'Waktunya Tidur! 😴',
          message: 'Sudah waktunya tidur untuk kesehatan yang optimal. Matikan gadget dan istirahat!',
          type: ReminderType.sleep,
          priority: ReminderPriority.medium,
          createdAt: now,
          context: {'reason': 'bedtime_reminder'},
        );
      }
    }

    return null;
  }

  // Generate reminder minum air
  Future<SmartReminder?> _generateWaterReminder(DateTime now, ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final lastWaterTime = prefs.getString('last_water_time');
    
    if (lastWaterTime == null) {
      return SmartReminder(
        id: _uuid.v4(),
        title: 'Minum Air! 💧',
        message: 'Jangan lupa minum air untuk menjaga hidrasi tubuh!',
        type: ReminderType.water,
        priority: ReminderPriority.medium,
        createdAt: now,
        context: {'reason': 'first_water_reminder'},
      );
    }

    final lastWater = DateTime.parse(lastWaterTime);
    final minutesSinceLastWater = now.difference(lastWater).inMinutes;
    
    if (minutesSinceLastWater >= settings.waterIntervalMinutes) {
      String message;
      ReminderPriority priority;
      
      if (minutesSinceLastWater >= 240) { // 4 jam
        message = 'Kamu belum minum air selama ${(minutesSinceLastWater / 60).toInt()} jam! Saatnya hidrasi!';
        priority = ReminderPriority.high;
      } else if (minutesSinceLastWater >= 180) { // 3 jam
        message = 'Sudah ${(minutesSinceLastWater / 60).toInt()} jam sejak minum terakhir. Jangan lupa minum air!';
        priority = ReminderPriority.medium;
      } else {
        message = 'Waktunya minum air untuk menjaga hidrasi tubuh!';
        priority = ReminderPriority.low;
      }

      return SmartReminder(
        id: _uuid.v4(),
        title: 'Minum Air! 💧',
        message: message,
        type: ReminderType.water,
        priority: priority,
        createdAt: now,
        context: {
          'minutes_since_last_water': minutesSinceLastWater,
          'last_water_time': lastWater.toIso8601String(),
        },
      );
    }

    return null;
  }

  // Generate reminder istirahat
  Future<SmartReminder?> _generateBreakReminder(List<StepData> stepHistory, DateTime now, ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final lastBreakTime = prefs.getString('last_break_time');
    
    if (lastBreakTime == null) {
      return SmartReminder(
        id: _uuid.v4(),
        title: 'Waktunya Istirahat! ☕',
        message: 'Istirahat sebentar untuk refresh pikiran dan tubuh!',
        type: ReminderType.rest,
        priority: ReminderPriority.low,
        createdAt: now,
        context: {'reason': 'first_break_reminder'},
      );
    }

    final lastBreak = DateTime.parse(lastBreakTime);
    final minutesSinceLastBreak = now.difference(lastBreak).inMinutes;
    
    if (minutesSinceLastBreak >= settings.breakIntervalMinutes) {
      String message;
      ReminderPriority priority;
      
      if (minutesSinceLastBreak >= 180) { // 3 jam
        message = 'Kamu sudah fokus selama ${(minutesSinceLastBreak / 60).toInt()} jam! Saatnya istirahat!';
        priority = ReminderPriority.medium;
      } else {
        message = 'Sudah ${minutesSinceLastBreak} menit bekerja. Waktunya istirahat sebentar!';
        priority = ReminderPriority.low;
      }

      return SmartReminder(
        id: _uuid.v4(),
        title: 'Waktunya Istirahat! ☕',
        message: message,
        type: ReminderType.rest,
        priority: priority,
        createdAt: now,
        context: {
          'minutes_since_last_break': minutesSinceLastBreak,
          'last_break_time': lastBreak.toIso8601String(),
        },
      );
    }

    return null;
  }

  // Simpan reminder
  Future<void> saveReminder(SmartReminder reminder) async {
    try {
      final userId = SupabaseService().currentUserId;
      if (userId != null) {
        // Simpan ke Supabase
        await _supabase.from('smart_reminders').upsert({
          'id': reminder.id,
          'user_id': userId,
          'title': reminder.title,
          'message': reminder.message,
          'type': reminder.type.toString().split('.').last,
          'priority': reminder.priority.toString().split('.').last,
          'created_at': reminder.createdAt.toIso8601String(),
          'triggered_at': reminder.triggeredAt?.toIso8601String(),
          'is_active': reminder.isActive,
          'context': reminder.context,
        });
        return;
      }
    } catch (e) {
      print('Error saving reminder to Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getReminders();
    
    final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);
    
    if (existingIndex >= 0) {
      reminders[existingIndex] = reminder;
    } else {
      reminders.add(reminder);
    }
    
    await prefs.setString(_remindersKey, jsonEncode(reminders.map((r) => r.toJson()).toList()));
  }

  // Ambil semua reminders
  Future<List<SmartReminder>> getReminders() async {
    try {
      final userId = SupabaseService().currentUserId;
      if (userId != null) {
        // Ambil dari Supabase
        final response = await _supabase
            .from('smart_reminders')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        
        if (response.isNotEmpty) {
          return response.map((json) {
            // Buat SmartReminder langsung dengan enum
            return SmartReminder(
              id: json['id'],
              title: json['title'],
              message: json['message'],
              type: ReminderType.values.firstWhere(
                (e) => e.toString().split('.').last == json['type'],
                orElse: () => ReminderType.meal,
              ),
              priority: ReminderPriority.values.firstWhere(
                (e) => e.toString().split('.').last == json['priority'],
                orElse: () => ReminderPriority.medium,
              ),
              createdAt: DateTime.parse(json['created_at']),
              triggeredAt: json['triggered_at'] != null 
                  ? DateTime.parse(json['triggered_at']) 
                  : null,
              isActive: json['is_active'] ?? true,
              context: Map<String, dynamic>.from(json['context'] ?? {}),
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error getting reminders from Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final remindersString = prefs.getString(_remindersKey);
    
    if (remindersString != null) {
      final List<dynamic> remindersJson = jsonDecode(remindersString);
      return remindersJson.map((json) => SmartReminder.fromJson(json)).toList();
    }
    
    return [];
  }

  // Ambil reminder aktif
  Future<List<SmartReminder>> getActiveReminders() async {
    final reminders = await getReminders();
    return reminders.where((r) => r.isActive).toList();
  }

  // Mark reminder sebagai triggered
  Future<void> markReminderTriggered(String reminderId) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((r) => r.id == reminderId);
    
    if (index >= 0) {
      reminders[index] = reminders[index].copyWith(
        triggeredAt: DateTime.now(),
        isActive: false,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_remindersKey, jsonEncode(reminders.map((r) => r.toJson()).toList()));
    }
  }

  // Hapus reminder
  Future<void> deleteReminder(String reminderId) async {
    final reminders = await getReminders();
    reminders.removeWhere((r) => r.id == reminderId);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_remindersKey, jsonEncode(reminders.map((r) => r.toJson()).toList()));
  }

  // Simpan pengaturan reminder
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    try {
      final userId = SupabaseService().currentUserId;
      if (userId != null) {
        // Simpan ke Supabase
        await _supabase.from('reminder_settings').upsert({
          'user_id': userId,
          'enable_meal_reminders': settings.enableMealReminders,
          'enable_movement_reminders': settings.enableMovementReminders,
          'enable_sleep_reminders': settings.enableSleepReminders,
          'enable_water_reminders': settings.enableWaterReminders,
          'enable_break_reminders': settings.enableBreakReminders,
          'meal_interval_hours': settings.mealIntervalHours,
          'movement_interval_minutes': settings.movementIntervalMinutes,
          'water_interval_minutes': settings.waterIntervalMinutes,
          'break_interval_minutes': settings.breakIntervalMinutes,
          'quiet_hours': settings.quietHours,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
        return;
      }
    } catch (e) {
      print('Error saving reminder settings to Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // Ambil pengaturan reminder
  Future<ReminderSettings> getReminderSettings() async {
    try {
      final userId = SupabaseService().currentUserId;
      if (userId != null) {
        // Ambil dari Supabase
        final response = await _supabase
            .from('reminder_settings')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        
        if (response != null) {
          return ReminderSettings.fromJson({
            'enableMealReminders': response['enable_meal_reminders'],
            'enableMovementReminders': response['enable_movement_reminders'],
            'enableSleepReminders': response['enable_sleep_reminders'],
            'enableWaterReminders': response['enable_water_reminders'],
            'enableBreakReminders': response['enable_break_reminders'],
            'mealIntervalHours': response['meal_interval_hours'],
            'movementIntervalMinutes': response['movement_interval_minutes'],
            'waterIntervalMinutes': response['water_interval_minutes'],
            'breakIntervalMinutes': response['break_interval_minutes'],
            'quietHours': response['quiet_hours'],
          });
        }
      }
    } catch (e) {
      print('Error getting reminder settings from Supabase: $e');
    }
    
    // Fallback ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey);
    
    if (settingsString != null) {
      final Map<String, dynamic> settingsJson = jsonDecode(settingsString);
      return ReminderSettings.fromJson(settingsJson);
    }
    
    return ReminderSettings(); // Default settings
  }

  // Track aktivitas untuk reminder
  Future<void> trackActivity(String activityType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_${activityType}_time', DateTime.now().toIso8601String());
  }

  // Cek apakah dalam jam tenang
  bool isQuietTime(DateTime now, List<String> quietHours) {
    if (quietHours.length != 2) return false;
    
    final startTime = quietHours[0].split(':');
    final endTime = quietHours[1].split(':');
    
    final startHour = int.parse(startTime[0]);
    final startMinute = int.parse(startTime[1]);
    final endHour = int.parse(endTime[0]);
    final endMinute = int.parse(endTime[1]);
    
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    
    if (startMinutes < endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // Cross midnight
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  // Clear old reminders (older than 7 days)
  Future<void> clearOldReminders() async {
    final reminders = await getReminders();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final activeReminders = reminders.where((r) => 
      r.createdAt.isAfter(weekAgo) || r.isActive
    ).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_remindersKey, jsonEncode(activeReminders.map((r) => r.toJson()).toList()));
  }
}
