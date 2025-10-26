import 'package:flutter/material.dart';
import '../services/trend_service.dart';

class TrendCard extends StatelessWidget {
  final WeeklyTrend trend;

  const TrendCard({
    super.key,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    Color iconColor;
    IconData icon;
    
    switch (trend.trend) {
      case 'up':
        cardColor = Colors.green;
        iconColor = Colors.green[700]!;
        icon = Icons.trending_up;
        break;
      case 'down':
        cardColor = Colors.red;
        iconColor = Colors.red[700]!;
        icon = Icons.trending_down;
        break;
      default:
        cardColor = Colors.blue;
        iconColor = Colors.blue[700]!;
        icon = Icons.trending_flat;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cardColor.withOpacity(0.1), cardColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: cardColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trend.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueCard(
                  'Minggu Ini',
                  _formatValue(trend.currentWeek),
                  iconColor,
                ),
                _buildValueCard(
                  'Minggu Lalu',
                  _formatValue(trend.previousWeek),
                  Colors.grey[600]!,
                ),
                _buildPercentageCard(
                  trend.percentageChange,
                  cardColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageCard(double percentage, Color color) {
    final isPositive = percentage >= 0;
    final displayPercentage = percentage.abs();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${displayPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isPositive ? 'Naik' : 'Turun',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(1);
  }
}
