import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NutritionChart extends StatelessWidget {
  final Map<String, double> nutrition;
  final String title;

  const NutritionChart({
    super.key,
    required this.nutrition,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [
      PieChartSectionData(
        color: Colors.blue,
        value: nutrition['protein'] ?? 0,
        title: 'Protein\n${(nutrition['protein'] ?? 0).toStringAsFixed(1)}g',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: nutrition['carbs'] ?? 0,
        title: 'Carbs\n${(nutrition['carbs'] ?? 0).toStringAsFixed(1)}g',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: nutrition['fat'] ?? 0,
        title: 'Fat\n${(nutrition['fat'] ?? 0).toStringAsFixed(1)}g',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Protein', Colors.blue),
                _buildLegendItem('Carbs', Colors.green),
                _buildLegendItem('Fat', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
