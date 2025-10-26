import 'package:flutter/material.dart';
import '../services/sleep_service.dart';
import '../services/activity_monitor_service.dart';
import '../models/sleep_data.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final SleepService _sleepService = SleepService();
  final ActivityMonitorService _monitorService = ActivityMonitorService();
  List<SleepData> _sleepHistory = [];
  DateTime? _bedTime;
  DateTime? _wakeTime;
  int _sleepQuality = 3;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await _sleepService.getSleepHistory(7);
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
          'Pemantauan Tidur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple[600],
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
              // Add sleep data card
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
                      colors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catat Tidur Anda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddSleepDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Data Tidur'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
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
              
              // Sleep statistics
              if (_sleepHistory.isNotEmpty) ...[
                const Text(
                  'Statistik Tidur',
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
                        'Rata-rata',
                        '${_sleepService.getAverageSleepHours(_sleepHistory).toStringAsFixed(1)} jam',
                        Icons.bedtime,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Kualitas',
                        '${_sleepService.getAverageSleepQuality(_sleepHistory).toStringAsFixed(1)}/5',
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Sleep history
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

  Widget _buildHistoryItem(SleepData data) {
    final date = data.date;
    final dayName = _getDayName(date.weekday);
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
          '$dayName, ${date.day}/${date.month}',
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

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  void _showAddSleepDialog() {
    DateTime? bedTime = _bedTime;
    DateTime? wakeTime = _wakeTime;
    int sleepQuality = _sleepQuality;
    String notes = _notes;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Data Tidur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Waktu Tidur'),
                  subtitle: Text(bedTime != null 
                    ? '${bedTime!.hour.toString().padLeft(2, '0')}:${bedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Pilih waktu'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: bedTime != null 
                        ? TimeOfDay.fromDateTime(bedTime!)
                        : TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() {
                        bedTime = DateTime.now().copyWith(
                          hour: time.hour,
                          minute: time.minute,
                        );
                        // Auto-calculate sleep quality based on duration
                        if (wakeTime != null) {
                          sleepQuality = _calculateSleepQuality(bedTime!, wakeTime!);
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Waktu Bangun'),
                  subtitle: Text(wakeTime != null 
                    ? '${wakeTime!.hour.toString().padLeft(2, '0')}:${wakeTime!.minute.toString().padLeft(2, '0')}'
                    : 'Pilih waktu'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: wakeTime != null 
                        ? TimeOfDay.fromDateTime(wakeTime!)
                        : TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() {
                        wakeTime = DateTime.now().copyWith(
                          hour: time.hour,
                          minute: time.minute,
                        );
                        // Auto-calculate sleep quality based on duration
                        if (bedTime != null) {
                          sleepQuality = _calculateSleepQuality(bedTime!, wakeTime!);
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Kualitas Tidur'),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setDialogState(() {
                          sleepQuality = index + 1;
                        });
                      },
                      icon: Icon(
                        index < sleepQuality ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
                // Show sleep duration and quality info
                if (bedTime != null && wakeTime != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durasi Tidur: ${_formatSleepDuration(bedTime!, wakeTime!)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kualitas: $sleepQuality/5 bintang',
                          style: TextStyle(
                            color: Colors.purple[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    notes = value;
                  },
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
              onPressed: bedTime != null && wakeTime != null ? () => _saveSleepData(bedTime!, wakeTime!, sleepQuality, notes) : null,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSleepQuality(DateTime bedTime, DateTime wakeTime) {
    Duration sleepDuration;
    
    if (wakeTime.isBefore(bedTime)) {
      // Handle overnight sleep
      final adjustedWakeTime = wakeTime.add(const Duration(days: 1));
      sleepDuration = adjustedWakeTime.difference(bedTime);
    } else {
      sleepDuration = wakeTime.difference(bedTime);
    }
    
    final sleepHours = sleepDuration.inHours + (sleepDuration.inMinutes % 60) / 60.0;
    
    // 7-9 jam = 5 bintang, 6-7 jam = 4 bintang, 5-6 jam = 3 bintang, 4-5 jam = 2 bintang, <4 jam = 1 bintang
    if (sleepHours >= 7 && sleepHours <= 9) {
      return 5;
    } else if (sleepHours >= 6 && sleepHours < 7) {
      return 4;
    } else if (sleepHours >= 5 && sleepHours < 6) {
      return 3;
    } else if (sleepHours >= 4 && sleepHours < 5) {
      return 2;
    } else {
      return 1;
    }
  }

  String _formatSleepDuration(DateTime bedTime, DateTime wakeTime) {
    Duration sleepDuration;
    
    if (wakeTime.isBefore(bedTime)) {
      // Handle overnight sleep
      final adjustedWakeTime = wakeTime.add(const Duration(days: 1));
      sleepDuration = adjustedWakeTime.difference(bedTime);
    } else {
      sleepDuration = wakeTime.difference(bedTime);
    }
    
    final hours = sleepDuration.inHours;
    final minutes = sleepDuration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}j ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> _saveSleepData(DateTime bedTime, DateTime wakeTime, int sleepQuality, String notes) async {
    Duration sleepDuration;
    
    if (wakeTime.isBefore(bedTime)) {
      // Handle overnight sleep
      final adjustedWakeTime = wakeTime.add(const Duration(days: 1));
      sleepDuration = adjustedWakeTime.difference(bedTime);
    } else {
      sleepDuration = wakeTime.difference(bedTime);
    }
    
    final sleepData = SleepData(
      date: DateTime.now(),
      bedTime: bedTime,
      wakeTime: wakeTime,
      totalSleep: sleepDuration,
      sleepQuality: sleepQuality,
      notes: notes,
    );
    
    await _sleepService.saveSleepData(sleepData);
    // Track sleep activity
    await _monitorService.trackMovement();
    
    Navigator.pop(context);
    _loadData();
    
    // Reset form
    setState(() {
      _bedTime = null;
      _wakeTime = null;
      _sleepQuality = 3;
      _notes = '';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data tidur berhasil disimpan: ${_formatSleepDuration(bedTime, wakeTime)}'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
