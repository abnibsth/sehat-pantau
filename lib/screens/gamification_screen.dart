import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import '../models/badge.dart' as models;
import '../widgets/badge_widget.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  final GamificationService _gamificationService = GamificationService();
  List<models.Badge> _badges = [];
  List<models.Achievement> _achievements = [];
  int _currentStreak = 0;
  int _totalPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final badges = await _gamificationService.getUserBadges();
      final achievements = await _gamificationService.getUserAchievements();
      final streak = await _gamificationService.getCurrentStreak();
      final points = await _gamificationService.getTotalPoints();

      setState(() {
        _badges = badges;
        _achievements = achievements;
        _currentStreak = streak;
        _totalPoints = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading gamification data: $e'),
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
          'Gamifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadGamificationData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan stats
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple[600]!, Colors.purple[400]!],
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
                            'Pencapaian & Badge',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kumpulkan badge dan capai target harian!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Streak',
                            '$_currentStreak hari',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Poin',
                            '$_totalPoints',
                            Icons.stars,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Badges Section
                    const Text(
                      'Badge Koleksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_badges.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Belum ada badge yang dikumpulkan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _badges.length,
                        itemBuilder: (context, index) {
                          final badge = _badges[index];
                          return BadgeWidget(
                            badge: badge,
                            onTap: () => _showBadgeDetails(badge),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Achievements Section
                    const Text(
                      'Pencapaian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_achievements.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Belum ada pencapaian',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._achievements.map((achievement) => _buildAchievementItem(achievement)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(models.Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: achievement.isCompleted ? Colors.green[100] : Colors.grey[100],
          child: Text(
            achievement.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: achievement.isCompleted ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        subtitle: Text(achievement.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${achievement.points} poin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.amber[600],
              ),
            ),
            if (achievement.isCompleted)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(models.Badge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(badge.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description),
            const SizedBox(height: 16),
            Text(
              'Target: ${badge.requirement}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Rarity: ${_getRarityText(badge.rarity)}',
              style: TextStyle(
                color: _getRarityColor(badge.rarity),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (badge.isUnlocked && badge.unlockedAt != null)
              Text(
                'Unlocked: ${badge.unlockedAt!.day}/${badge.unlockedAt!.month}/${badge.unlockedAt!.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _getRarityText(models.BadgeRarity rarity) {
    switch (rarity) {
      case models.BadgeRarity.common:
        return 'Common';
      case models.BadgeRarity.rare:
        return 'Rare';
      case models.BadgeRarity.epic:
        return 'Epic';
      case models.BadgeRarity.legendary:
        return 'Legendary';
    }
  }

  Color _getRarityColor(models.BadgeRarity rarity) {
    switch (rarity) {
      case models.BadgeRarity.common:
        return Colors.green;
      case models.BadgeRarity.rare:
        return Colors.blue;
      case models.BadgeRarity.epic:
        return Colors.purple;
      case models.BadgeRarity.legendary:
        return Colors.amber;
    }
  }
}
