import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/badge.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  static const String _badgesKey = 'user_badges';
  static const String _achievementsKey = 'user_achievements';
  static const String _streakKey = 'daily_streak';
  static const String _lastActiveDateKey = 'last_active_date';

  // Daftar badge yang tersedia
  static final List<Badge> _availableBadges = [
    // Steps Badges
    Badge(
      id: 'steps_1000',
      name: 'Prajurit Langkah',
      description: 'Capai 1,000 langkah dalam sehari',
      emoji: '🚶‍♂️',
      type: BadgeType.steps,
      rarity: BadgeRarity.common,
      requirement: 1000,
    ),
    Badge(
      id: 'steps_5000',
      name: 'Penjelajah',
      description: 'Capai 5,000 langkah dalam sehari',
      emoji: '🏃‍♂️',
      type: BadgeType.steps,
      rarity: BadgeRarity.rare,
      requirement: 5000,
    ),
    Badge(
      id: 'steps_10000',
      name: 'Si Rajin Jalan',
      description: 'Capai 10,000 langkah dalam sehari',
      emoji: '🏃‍♀️',
      type: BadgeType.steps,
      rarity: BadgeRarity.epic,
      requirement: 10000,
    ),
    Badge(
      id: 'steps_15000',
      name: 'Marathon Runner',
      description: 'Capai 15,000 langkah dalam sehari',
      emoji: '🏃‍♂️💨',
      type: BadgeType.steps,
      rarity: BadgeRarity.legendary,
      requirement: 15000,
    ),

    // Sleep Badges
    Badge(
      id: 'sleep_6h',
      name: 'Tukang Tidur',
      description: 'Tidur 6 jam dalam sehari',
      emoji: '😴',
      type: BadgeType.sleep,
      rarity: BadgeRarity.common,
      requirement: 6,
    ),
    Badge(
      id: 'sleep_8h',
      name: 'Sleep Master',
      description: 'Tidur 8 jam dalam sehari',
      emoji: '😌',
      type: BadgeType.sleep,
      rarity: BadgeRarity.rare,
      requirement: 8,
    ),
    Badge(
      id: 'sleep_9h',
      name: 'Sleep Champion',
      description: 'Tidur 9 jam dalam sehari',
      emoji: '🛌',
      type: BadgeType.sleep,
      rarity: BadgeRarity.epic,
      requirement: 9,
    ),

    // Calories Badges
    Badge(
      id: 'calories_1500',
      name: 'Prajurit Kalori',
      description: 'Konsumsi 1,500 kalori dalam sehari',
      emoji: '🔥',
      type: BadgeType.calories,
      rarity: BadgeRarity.common,
      requirement: 1500,
    ),
    Badge(
      id: 'calories_2000',
      name: 'Kalori King',
      description: 'Konsumsi 2,000 kalori dalam sehari',
      emoji: '🍽️',
      type: BadgeType.calories,
      rarity: BadgeRarity.rare,
      requirement: 2000,
    ),
    Badge(
      id: 'calories_2500',
      name: 'Kalori Master',
      description: 'Konsumsi 2,500 kalori dalam sehari',
      emoji: '🍔',
      type: BadgeType.calories,
      rarity: BadgeRarity.epic,
      requirement: 2500,
    ),

    // Streak Badges
    Badge(
      id: 'streak_3',
      name: 'Konsisten 3 Hari',
      description: 'Capai target 3 hari berturut-turut',
      emoji: '🔥',
      type: BadgeType.streak,
      rarity: BadgeRarity.common,
      requirement: 3,
    ),
    Badge(
      id: 'streak_7',
      name: 'Konsisten 7 Hari',
      description: 'Capai target 7 hari berturut-turut',
      emoji: '💪',
      type: BadgeType.streak,
      rarity: BadgeRarity.rare,
      requirement: 7,
    ),
    Badge(
      id: 'streak_14',
      name: 'Konsisten 14 Hari',
      description: 'Capai target 14 hari berturut-turut',
      emoji: '🏆',
      type: BadgeType.streak,
      rarity: BadgeRarity.epic,
      requirement: 14,
    ),
    Badge(
      id: 'streak_30',
      name: 'Konsisten 30 Hari',
      description: 'Capai target 30 hari berturut-turut',
      emoji: '👑',
      type: BadgeType.streak,
      rarity: BadgeRarity.legendary,
      requirement: 30,
    ),
  ];

  // Daftar achievement yang tersedia
  static final List<Achievement> _availableAchievements = [
    Achievement(
      id: 'first_steps',
      title: 'Langkah Pertama',
      description: 'Lengkapi data langkah pertama Anda',
      emoji: '👣',
      points: 10,
    ),
    Achievement(
      id: 'first_sleep',
      title: 'Tidur Pertama',
      description: 'Lengkapi data tidur pertama Anda',
      emoji: '🌙',
      points: 10,
    ),
    Achievement(
      id: 'first_food',
      title: 'Makanan Pertama',
      description: 'Lengkapi data makanan pertama Anda',
      emoji: '🍎',
      points: 10,
    ),
    Achievement(
      id: 'week_complete',
      title: 'Seminggu Penuh',
      description: 'Gunakan aplikasi selama 7 hari',
      emoji: '📅',
      points: 50,
    ),
    Achievement(
      id: 'month_complete',
      title: 'Sebulan Penuh',
      description: 'Gunakan aplikasi selama 30 hari',
      emoji: '🗓️',
      points: 100,
    ),
  ];

  // Cek dan unlock badge berdasarkan data harian
  Future<List<Badge>> checkAndUnlockBadges({
    required int steps,
    required double sleepHours,
    required double calories,
  }) async {
    final userBadges = await getUserBadges();
    final List<Badge> newBadges = [];

    for (Badge badge in _availableBadges) {
      // Skip jika badge sudah di-unlock
      if (userBadges.any((b) => b.id == badge.id && b.isUnlocked)) {
        continue;
      }

      bool shouldUnlock = false;

      switch (badge.type) {
        case BadgeType.steps:
          shouldUnlock = steps >= badge.requirement;
          break;
        case BadgeType.sleep:
          shouldUnlock = sleepHours >= badge.requirement;
          break;
        case BadgeType.calories:
          shouldUnlock = calories >= badge.requirement;
          break;
        case BadgeType.streak:
          final currentStreak = await getCurrentStreak();
          shouldUnlock = currentStreak >= badge.requirement;
          break;
        case BadgeType.consistency:
          // Implementasi consistency badge nanti
          break;
      }

      if (shouldUnlock) {
        final unlockedBadge = badge.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        newBadges.add(unlockedBadge);
        await _saveBadge(unlockedBadge);
      }
    }

    return newBadges;
  }

  // Cek dan unlock achievement
  Future<List<Achievement>> checkAndUnlockAchievements() async {
    final userAchievements = await getUserAchievements();
    final List<Achievement> newAchievements = [];

    for (Achievement achievement in _availableAchievements) {
      // Skip jika achievement sudah di-unlock
      if (userAchievements.any((a) => a.id == achievement.id && a.isCompleted)) {
        continue;
      }

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_steps':
          // Cek apakah sudah ada data langkah
          shouldUnlock = await _hasStepData();
          break;
        case 'first_sleep':
          // Cek apakah sudah ada data tidur
          shouldUnlock = await _hasSleepData();
          break;
        case 'first_food':
          // Cek apakah sudah ada data makanan
          shouldUnlock = await _hasFoodData();
          break;
        case 'week_complete':
          // Cek apakah sudah 7 hari menggunakan aplikasi
          shouldUnlock = await _hasUsedAppForDays(7);
          break;
        case 'month_complete':
          // Cek apakah sudah 30 hari menggunakan aplikasi
          shouldUnlock = await _hasUsedAppForDays(30);
          break;
      }

      if (shouldUnlock) {
        final unlockedAchievement = Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          emoji: achievement.emoji,
          points: achievement.points,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        newAchievements.add(unlockedAchievement);
        await _saveAchievement(unlockedAchievement);
      }
    }

    return newAchievements;
  }

  // Update streak harian
  Future<void> updateDailyStreak({
    required int steps,
    required double sleepHours,
    required double calories,
  }) async {
    final today = DateTime.now();
    
    final prefs = await SharedPreferences.getInstance();
    final lastActiveDateString = prefs.getString(_lastActiveDateKey);
    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    // Cek apakah target harian tercapai
    final isTargetReached = _isDailyTargetReached(
      steps: steps,
      sleepHours: sleepHours,
      calories: calories,
    );

    if (isTargetReached) {
      if (lastActiveDateString == null) {
        // Pertama kali menggunakan aplikasi
        await prefs.setString(_lastActiveDateKey, today.toIso8601String());
        await prefs.setInt(_streakKey, 1);
      } else {
        final lastActiveDate = DateTime.parse(lastActiveDateString);
        final daysDifference = today.difference(lastActiveDate).inDays;

        if (daysDifference == 1) {
          // Streak berlanjut
          await prefs.setInt(_streakKey, currentStreak + 1);
          await prefs.setString(_lastActiveDateKey, today.toIso8601String());
        } else if (daysDifference == 0) {
          // Hari yang sama, tidak perlu update streak
        } else {
          // Streak terputus, reset
          await prefs.setInt(_streakKey, 1);
          await prefs.setString(_lastActiveDateKey, today.toIso8601String());
        }
      }
    }
  }

  // Cek apakah target harian tercapai
  bool _isDailyTargetReached({
    required int steps,
    required double sleepHours,
    required double calories,
  }) {
    const int targetSteps = 10000;
    const double targetSleep = 7.0;
    const double targetCalories = 2000.0;

    return steps >= targetSteps && 
           sleepHours >= targetSleep && 
           calories >= targetCalories;
  }

  // Get current streak
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  // Get user badges
  Future<List<Badge>> getUserBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final badgesString = prefs.getString(_badgesKey);
    
    if (badgesString != null) {
      final List<dynamic> badgesJson = jsonDecode(badgesString);
      return badgesJson.map((json) => Badge.fromJson(json)).toList();
    }
    
    return [];
  }

  // Get user achievements
  Future<List<Achievement>> getUserAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsString = prefs.getString(_achievementsKey);
    
    if (achievementsString != null) {
      final List<dynamic> achievementsJson = jsonDecode(achievementsString);
      return achievementsJson.map((json) => Achievement.fromJson(json)).toList();
    }
    
    return [];
  }

  // Save badge
  Future<void> _saveBadge(Badge badge) async {
    final userBadges = await getUserBadges();
    final existingIndex = userBadges.indexWhere((b) => b.id == badge.id);
    
    if (existingIndex >= 0) {
      userBadges[existingIndex] = badge;
    } else {
      userBadges.add(badge);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_badgesKey, jsonEncode(userBadges.map((b) => b.toJson()).toList()));
  }

  // Save achievement
  Future<void> _saveAchievement(Achievement achievement) async {
    final userAchievements = await getUserAchievements();
    final existingIndex = userAchievements.indexWhere((a) => a.id == achievement.id);
    
    if (existingIndex >= 0) {
      userAchievements[existingIndex] = achievement;
    } else {
      userAchievements.add(achievement);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_achievementsKey, jsonEncode(userAchievements.map((a) => a.toJson()).toList()));
  }

  // Helper methods untuk cek data
  Future<bool> _hasStepData() async {
    // Implementasi cek data langkah
    return true; // Placeholder
  }

  Future<bool> _hasSleepData() async {
    // Implementasi cek data tidur
    return true; // Placeholder
  }

  Future<bool> _hasFoodData() async {
    // Implementasi cek data makanan
    return true; // Placeholder
  }

  Future<bool> _hasUsedAppForDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final firstUseString = prefs.getString('first_use_date');
    
    if (firstUseString == null) {
      // Set first use date
      await prefs.setString('first_use_date', DateTime.now().toIso8601String());
      return false;
    }
    
    final firstUse = DateTime.parse(firstUseString);
    final daysSinceFirstUse = DateTime.now().difference(firstUse).inDays;
    
    return daysSinceFirstUse >= days;
  }

  // Get total points
  Future<int> getTotalPoints() async {
    final achievements = await getUserAchievements();
    return achievements.fold<int>(0, (sum, achievement) => sum + achievement.points);
  }

  // Get badge count by rarity
  Future<Map<BadgeRarity, int>> getBadgeCountByRarity() async {
    final badges = await getUserBadges();
    final Map<BadgeRarity, int> count = {};
    
    for (BadgeRarity rarity in BadgeRarity.values) {
      count[rarity] = badges.where((b) => b.rarity == rarity && b.isUnlocked).length;
    }
    
    return count;
  }
}
