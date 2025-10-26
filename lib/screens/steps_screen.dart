import 'package:flutter/material.dart';
import '../services/step_service.dart';
import '../services/activity_monitor_service.dart';
import '../models/step_data.dart';
import '../widgets/step_progress.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final StepService _stepService = StepService();
  final ActivityMonitorService _monitorService = ActivityMonitorService();
  int _currentSteps = 0;
  List<StepData> _stepHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _stepService.initialize();
    final history = await _stepService.getStepHistory(7);
    
    setState(() {
      _currentSteps = _stepService.currentSteps;
      _stepHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pelacakan Langkah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add manual step input card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Input Manual Data Langkah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showManualInputDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Data Langkah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Today's progress
              StepProgress(
                currentSteps: _currentSteps,
                targetSteps: 10000,
                progress: _currentSteps / 10000.0,
              ),
              
              const SizedBox(height: 16),
              
              // Today's stats
              if (_stepHistory.isNotEmpty)
                Card(
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
                          'Statistik Hari Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Jarak',
                                '${(_stepHistory.first.distance / 1000).toStringAsFixed(2)} km',
                                Icons.straighten,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Kalori',
                                '${_stepHistory.first.calories} kcal',
                                Icons.local_fire_department,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Jarak',
                      '${(_currentSteps * 0.7 / 1000).toStringAsFixed(1)} km',
                      Icons.straighten,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Kalori',
                      '${(_currentSteps * 0.04).toInt()} kcal',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Weekly history
              const Text(
                'Riwayat 7 Hari Terakhir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_stepHistory.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Belum ada data langkah',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ..._stepHistory.map((data) => _buildHistoryItem(data)),
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

  Widget _buildHistoryItem(StepData data) {
    final date = data.date;
    final dayName = _getDayName(date.weekday);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(
            Icons.directions_walk,
            color: Colors.blue[600],
          ),
        ),
        title: Text(
          '$dayName, ${date.day}/${date.month}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${data.steps} langkah • ${(data.distance / 1000).toStringAsFixed(1)} km',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${data.calories} kcal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: data.steps >= 10000 ? Colors.green[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                data.steps >= 10000 ? 'Target' : '${(data.steps / 10000 * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: data.steps >= 10000 ? Colors.green[700] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }


  void _showManualInputDialog() {
    int steps = 0;
    double distance = 0.0;
    int hours = 0;
    int minutes = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Input Manual Data Langkah'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Langkah',
                    border: OutlineInputBorder(),
                    suffixText: 'langkah',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    steps = int.tryParse(value) ?? 0;
                    setDialogState(() {}); // Update UI untuk refresh estimasi
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Jarak Tempuh',
                    border: OutlineInputBorder(),
                    suffixText: 'km',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    distance = double.tryParse(value) ?? 0.0;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Durasi (Jam)',
                          border: OutlineInputBorder(),
                          suffixText: 'jam',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          hours = int.tryParse(value) ?? 0;
                          setDialogState(() {}); // Update UI untuk refresh estimasi
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Durasi (Menit)',
                          border: OutlineInputBorder(),
                          suffixText: 'menit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          minutes = int.tryParse(value) ?? 0;
                          setDialogState(() {}); // Update UI untuk refresh estimasi
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimasi Kalori: ${(steps * 0.04).toInt()} kcal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Durasi: ${hours}h ${minutes}m',
                        style: TextStyle(
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: steps > 0 ? () => _saveManualData(steps, distance, hours, minutes) : null,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveManualData(int steps, double distance, int hours, int minutes) async {
    try {
      final today = DateTime.now();
      final calories = (steps * 0.04).round();
      
      final stepData = StepData(
        date: DateTime(today.year, today.month, today.day),
        steps: steps,
        distance: distance * 1000, // Convert km to meters
        calories: calories,
      );
      
      // Save manual step data
      await _stepService.saveManualStepData(stepData);
      // Track movement activity
      await _monitorService.trackMovement();
      
      Navigator.pop(context);
      
      // Reload data to show updated history
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data langkah berhasil disimpan: $steps langkah, ${distance}km, ${hours}h ${minutes}m'),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error menyimpan data: $e'),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
