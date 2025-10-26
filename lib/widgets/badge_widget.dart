import 'package:flutter/material.dart';
import '../models/badge.dart' as models;

class BadgeWidget extends StatefulWidget {
  final models.Badge badge;
  final bool showAnimation;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.showAnimation = false,
    this.onTap,
  });

  @override
  State<BadgeWidget> createState() => _BadgeWidgetState();
}

class _BadgeWidgetState extends State<BadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 0.1,
              child: _buildBadgeCard(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard() {
    final rarityColor = _getRarityColor(widget.badge.rarity);
    final isUnlocked = widget.badge.isUnlocked;

    return Container(
      width: 120,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isUnlocked
              ? [rarityColor.withOpacity(0.8), rarityColor.withOpacity(0.6)]
              : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked ? rarityColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUnlocked ? rarityColor : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.white : Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isUnlocked ? widget.badge.emoji : '🔒',
                style: TextStyle(
                  fontSize: 24,
                  color: isUnlocked ? null : Colors.grey[600],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Badge Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.badge.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Rarity Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isUnlocked ? rarityColor : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getRarityText(widget.badge.rarity),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
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
        return Colors.orange;
    }
  }

  String _getRarityText(models.BadgeRarity rarity) {
    switch (rarity) {
      case models.BadgeRarity.common:
        return 'COMMON';
      case models.BadgeRarity.rare:
        return 'RARE';
      case models.BadgeRarity.epic:
        return 'EPIC';
      case models.BadgeRarity.legendary:
        return 'LEGENDARY';
    }
  }
}

class BadgeGrid extends StatelessWidget {
  final List<models.Badge> badges;
  final Function(models.Badge)? onBadgeTap;

  const BadgeGrid({
    super.key,
    required this.badges,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return BadgeWidget(
          badge: badge,
          showAnimation: badge.isUnlocked && badge.unlockedAt != null &&
              DateTime.now().difference(badge.unlockedAt!).inMinutes < 1,
          onTap: () => onBadgeTap?.call(badge),
        );
      },
    );
  }
}

class StreakWidget extends StatefulWidget {
  final int currentStreak;
  final int targetStreak;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.targetStreak,
  });

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.currentStreak / widget.targetStreak;
    final isStreakComplete = widget.currentStreak >= widget.targetStreak;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isStreakComplete
                    ? [Colors.orange, Colors.red]
                    : [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isStreakComplete ? Colors.orange : Colors.blue).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isStreakComplete ? Icons.local_fire_department : Icons.trending_up,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Streak Harian',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.currentStreak} hari',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: ${widget.targetStreak} hari',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                if (isStreakComplete) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.celebration, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Streak Complete!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
