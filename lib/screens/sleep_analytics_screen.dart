import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/sleep_service.dart';
import '../models/sleep_data.dart';

class SleepAnalyticsScreen extends StatefulWidget {
  const SleepAnalyticsScreen({super.key});

  @override
  State<SleepAnalyticsScreen> createState() => _SleepAnalyticsScreenState();
}

class _SleepAnalyticsScreenState extends State<SleepAnalyticsScreen> {
  final SleepService _sleepService = SleepService();
  List<SleepData> _sleepHistory = [];
  String _selectedPeriod = 'week'; // week, month

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    final days = _selectedPeriod == 'week' ? 7 : 30;
    final history = await _sleepService.getSleepHistory(days);
    setState(() {
      _sleepHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Analisis Tidur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple[600],
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadSleepData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('7 Hari Terakhir'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('30 Hari Terakhir'),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSleepData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics cards
              _buildStatisticsCards(),
              
              const SizedBox(height: 24),
              
              // Sleep duration chart
              _buildSleepDurationChart(),
              
              const SizedBox(height: 24),
              
              // Sleep quality chart
              _buildSleepQualityChart(),
              
              const SizedBox(height: 24),
              
              // Sleep history
              _buildSleepHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final avgHours = _sleepService.getAverageSleepHours(_sleepHistory);
    final avgQuality = _sleepService.getAverageSleepQuality(_sleepHistory);
    final totalDays = _sleepHistory.length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Rata-rata Tidur',
            '${avgHours.toStringAsFixed(1)} jam',
            Icons.bedtime,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Kualitas Tidur',
            '${avgQuality.toStringAsFixed(1)}/5',
            Icons.star,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Hari',
            '$totalDays hari',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepDurationChart() {
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
            const Text(
              'Durasi Tidur (Jam)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _sleepHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada data tidur',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 12,
                        barTouchData: BarTouchData(enabled: false),
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
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < _sleepHistory.length) {
                                  final date = _sleepHistory[value.toInt()].date;
                                  return Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}h',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarGroups(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualityChart() {
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
            const Text(
              'Kualitas Tidur (Bintang)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _sleepHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada data tidur',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
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
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < _sleepHistory.length) {
                                  final date = _sleepHistory[value.toInt()].date;
                                  return Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}⭐',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _buildQualitySpots(),
                            isCurved: true,
                            color: Colors.amber,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.amber.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Tidur',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_sleepHistory.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Belum ada data tidur',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ..._sleepHistory.map((data) => _buildHistoryItem(data)),
      ],
    );
  }

  Widget _buildHistoryItem(SleepData data) {
    final date = data.date;
    final sleepHours = data.totalSleep.inHours;
    final sleepMinutes = data.totalSleep.inMinutes % 60;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Icon(
            Icons.bedtime,
            color: Colors.purple[600],
          ),
        ),
        title: Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${sleepHours}h ${sleepMinutes}m tidur'),
            if (data.notes.isNotEmpty) Text('Catatan: ${data.notes}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Icon(
                  index < data.sleepQuality ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '${data.bedTime.hour.toString().padLeft(2, '0')}:${data.bedTime.minute.toString().padLeft(2, '0')} - ${data.wakeTime.hour.toString().padLeft(2, '0')}:${data.wakeTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return _sleepHistory.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final hours = data.totalSleep.inHours + (data.totalSleep.inMinutes % 60) / 60.0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hours,
            color: Colors.purple,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  List<FlSpot> _buildQualitySpots() {
    return _sleepHistory.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final quality = entry.value.sleepQuality.toDouble();
      return FlSpot(index, quality);
    }).toList();
  }
}
