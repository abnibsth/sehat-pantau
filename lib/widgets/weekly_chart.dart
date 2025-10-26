import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final String title;
  final String dataType; // 'steps', 'sleep', 'calories'
  final Color color;

  const WeeklyChart({
    super.key,
    required this.chartData,
    required this.title,
    required this.dataType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Tidak ada data untuk ditampilkan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: _getInterval(),
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < chartData.length) {
                            return Text(
                              chartData[value.toInt()]['day'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getInterval(),
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatValue(value),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: 0,
                  maxX: (chartData.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.3)],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      double value = 0;
      
      switch (dataType) {
        case 'steps':
          value = data['steps'].toDouble();
          break;
        case 'sleep':
          value = data['sleep'].toDouble();
          break;
        case 'calories':
          value = data['calories'].toDouble();
          break;
      }
      
      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  double _getMaxY() {
    double maxValue = 0;
    
    for (var data in chartData) {
      double value = 0;
      switch (dataType) {
        case 'steps':
          value = data['steps'].toDouble();
          break;
        case 'sleep':
          value = data['sleep'].toDouble();
          break;
        case 'calories':
          value = data['calories'].toDouble();
          break;
      }
      if (value > maxValue) maxValue = value;
    }
    
    // Tambahkan 20% padding di atas nilai maksimum
    return maxValue * 1.2;
  }

  double _getInterval() {
    final maxY = _getMaxY();
    
    switch (dataType) {
      case 'steps':
        return maxY / 5; // 5 interval untuk langkah
      case 'sleep':
        return maxY / 4; // 4 interval untuk tidur
      case 'calories':
        return maxY / 5; // 5 interval untuk kalori
      default:
        return maxY / 5;
    }
  }

  String _formatValue(double value) {
    switch (dataType) {
      case 'steps':
        if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)}k';
        }
        return value.toInt().toString();
      case 'sleep':
        return '${value.toStringAsFixed(1)}h';
      case 'calories':
        return '${value.toInt()}';
      default:
        return value.toInt().toString();
    }
  }

  Widget _buildSummary() {
    final total = chartData.fold<double>(0, (sum, data) {
      switch (dataType) {
        case 'steps':
          return sum + data['steps'];
        case 'sleep':
          return sum + data['sleep'];
        case 'calories':
          return sum + data['calories'];
        default:
          return sum;
      }
    });

    final average = total / chartData.length;
    String unit = '';
    String formattedAverage = '';

    switch (dataType) {
      case 'steps':
        unit = 'langkah';
        formattedAverage = average >= 1000 
            ? '${(average / 1000).toStringAsFixed(1)}k'
            : average.toInt().toString();
        break;
      case 'sleep':
        unit = 'jam';
        formattedAverage = '${average.toStringAsFixed(1)}';
        break;
      case 'calories':
        unit = 'kalori';
        formattedAverage = average.toInt().toString();
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '${total.toInt()}', unit),
          _buildStatItem('Rata-rata', formattedAverage, unit),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '$label $unit',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
