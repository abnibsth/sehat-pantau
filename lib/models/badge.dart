enum BadgeType {
  steps,
  sleep,
  calories,
  streak,
  consistency,
}

enum BadgeRarity {
  common,    // Hijau
  rare,      // Biru
  epic,      // Ungu
  legendary, // Emas
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeType type;
  final BadgeRarity rarity;
  final int requirement; // Target yang harus dicapai
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.rarity,
    required this.requirement,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'type': type.toString(),
      'rarity': rarity.toString(),
      'requirement': requirement,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      type: BadgeType.values.firstWhere((e) => e.toString() == json['type']),
      rarity: BadgeRarity.values.firstWhere((e) => e.toString() == json['rarity']),
      requirement: json['requirement'],
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    BadgeType? type,
    BadgeRarity? rarity,
    int? requirement,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      requirement: requirement ?? this.requirement,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int points;
  final DateTime? completedAt;
  final bool isCompleted;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.points,
    this.completedAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'points': points,
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      emoji: json['emoji'],
      points: json['points'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
