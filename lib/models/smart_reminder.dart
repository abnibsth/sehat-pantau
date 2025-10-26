import 'package:flutter/material.dart';

enum ReminderType {
  meal,        // Makan
  movement,    // Gerakan
  sleep,       // Tidur
  water,       // Minum air
  rest,        // Istirahat
}

enum ReminderPriority {
  low,         // Rendah
  medium,      // Sedang
  high,        // Tinggi
  urgent,      // Mendesak
}

class SmartReminder {
  final String id;
  final String title;
  final String message;
  final ReminderType type;
  final ReminderPriority priority;
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final bool isActive;
  final Map<String, dynamic> context; // Data kontekstual

  SmartReminder({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.triggeredAt,
    this.isActive = true,
    this.context = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'priority': priority.toString(),
      'createdAt': createdAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
      'isActive': isActive,
      'context': context,
    };
  }

  factory SmartReminder.fromJson(Map<String, dynamic> json) {
    return SmartReminder(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ReminderType.meal,
      ),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      triggeredAt: json['triggeredAt'] != null 
          ? DateTime.parse(json['triggeredAt']) 
          : null,
      isActive: json['isActive'] ?? true,
      context: Map<String, dynamic>.from(json['context'] ?? {}),
    );
  }

  SmartReminder copyWith({
    String? id,
    String? title,
    String? message,
    ReminderType? type,
    ReminderPriority? priority,
    DateTime? createdAt,
    DateTime? triggeredAt,
    bool? isActive,
    Map<String, dynamic>? context,
  }) {
    return SmartReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      isActive: isActive ?? this.isActive,
      context: context ?? this.context,
    );
  }

  // Helper methods
  String get emoji {
    switch (type) {
      case ReminderType.meal:
        return '🍽️';
      case ReminderType.movement:
        return '🚶‍♂️';
      case ReminderType.sleep:
        return '😴';
      case ReminderType.water:
        return '💧';
      case ReminderType.rest:
        return '☕';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case ReminderPriority.low:
        return Colors.green;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.high:
        return Colors.red;
      case ReminderPriority.urgent:
        return Colors.purple;
    }
  }

  String get priorityText {
    switch (priority) {
      case ReminderPriority.low:
        return 'Rendah';
      case ReminderPriority.medium:
        return 'Sedang';
      case ReminderPriority.high:
        return 'Tinggi';
      case ReminderPriority.urgent:
        return 'Mendesak';
    }
  }
}

class ReminderSettings {
  final bool enableMealReminders;
  final bool enableMovementReminders;
  final bool enableSleepReminders;
  final bool enableWaterReminders;
  final bool enableBreakReminders;
  final int mealIntervalHours;
  final int movementIntervalMinutes;
  final int waterIntervalMinutes;
  final int breakIntervalMinutes;
  final List<String> quietHours; // Jam tenang (tidak ada notifikasi)

  ReminderSettings({
    this.enableMealReminders = true,
    this.enableMovementReminders = true,
    this.enableSleepReminders = true,
    this.enableWaterReminders = true,
    this.enableBreakReminders = true,
    this.mealIntervalHours = 4,
    this.movementIntervalMinutes = 60,
    this.waterIntervalMinutes = 120,
    this.breakIntervalMinutes = 90,
    this.quietHours = const ['22:00', '07:00'],
  });

  Map<String, dynamic> toJson() {
    return {
      'enableMealReminders': enableMealReminders,
      'enableMovementReminders': enableMovementReminders,
      'enableSleepReminders': enableSleepReminders,
      'enableWaterReminders': enableWaterReminders,
      'enableBreakReminders': enableBreakReminders,
      'mealIntervalHours': mealIntervalHours,
      'movementIntervalMinutes': movementIntervalMinutes,
      'waterIntervalMinutes': waterIntervalMinutes,
      'breakIntervalMinutes': breakIntervalMinutes,
      'quietHours': quietHours,
    };
  }

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      enableMealReminders: json['enableMealReminders'] ?? true,
      enableMovementReminders: json['enableMovementReminders'] ?? true,
      enableSleepReminders: json['enableSleepReminders'] ?? true,
      enableWaterReminders: json['enableWaterReminders'] ?? true,
      enableBreakReminders: json['enableBreakReminders'] ?? true,
      mealIntervalHours: json['mealIntervalHours'] ?? 4,
      movementIntervalMinutes: json['movementIntervalMinutes'] ?? 60,
      waterIntervalMinutes: json['waterIntervalMinutes'] ?? 120,
      breakIntervalMinutes: json['breakIntervalMinutes'] ?? 90,
      quietHours: List<String>.from(json['quietHours'] ?? ['22:00', '07:00']),
    );
  }
}
