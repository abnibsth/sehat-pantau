import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'smart_reminder_service.dart';
import 'step_service.dart';
import 'sleep_service.dart';
import 'food_service.dart';

class ActivityMonitorService {
  static final ActivityMonitorService _instance = ActivityMonitorService._internal();
  factory ActivityMonitorService() => _instance;
  ActivityMonitorService._internal();

  Timer? _monitoringTimer;
  final SmartReminderService _reminderService = SmartReminderService();
  final StepService _stepService = StepService();
  final SleepService _sleepService = SleepService();
  final FoodService _foodService = FoodService();

  bool _isMonitoring = false;
  DateTime? _lastActivityCheck;

  // Start monitoring aktivitas pengguna
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _lastActivityCheck = DateTime.now();
    
    // Check setiap 5 menit
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _checkAndGenerateReminders(),
    );
    
    print('Activity monitoring started');
  }

  // Stop monitoring
  Future<void> stopMonitoring() async {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
    print('Activity monitoring stopped');
  }

  // Check dan generate reminders berdasarkan aktivitas
  Future<void> _checkAndGenerateReminders() async {
    try {
      // Ambil data terbaru (7 hari terakhir)
      final stepHistory = await _stepService.getStepHistory(7);
      final sleepHistory = await _sleepService.getSleepHistory(7);
      final foodHistory = await _foodService.getFoodHistory(7);

      // Generate smart reminders
      final newReminders = await _reminderService.generateSmartReminders(
        stepHistory: stepHistory,
        sleepHistory: sleepHistory,
        foodHistory: foodHistory,
      );

      // Simpan reminders baru
      for (final reminder in newReminders) {
        await _reminderService.saveReminder(reminder);
      }

      // Update last check time
      _lastActivityCheck = DateTime.now();
      
      print('Generated ${newReminders.length} new reminders');
    } catch (e) {
      print('Error in activity monitoring: $e');
    }
  }

  // Manual check untuk testing
  Future<void> checkNow() async {
    await _checkAndGenerateReminders();
  }

  // Track specific activities
  Future<void> trackMeal() async {
    await _reminderService.trackActivity('meal');
    await _checkAndGenerateReminders();
  }

  Future<void> trackWater() async {
    await _reminderService.trackActivity('water');
    await _checkAndGenerateReminders();
  }

  Future<void> trackBreak() async {
    await _reminderService.trackActivity('break');
    await _checkAndGenerateReminders();
  }

  Future<void> trackMovement() async {
    await _reminderService.trackActivity('movement');
    await _checkAndGenerateReminders();
  }

  // Get monitoring status
  bool get isMonitoring => _isMonitoring;
  DateTime? get lastActivityCheck => _lastActivityCheck;

  // Cleanup old data
  Future<void> cleanup() async {
    await _reminderService.clearOldReminders();
  }
}

// Background service untuk monitoring
class BackgroundActivityMonitor {
  static final BackgroundActivityMonitor _instance = BackgroundActivityMonitor._internal();
  factory BackgroundActivityMonitor() => _instance;
  BackgroundActivityMonitor._internal();

  final ActivityMonitorService _monitorService = ActivityMonitorService();
  Timer? _backgroundTimer;

  // Start background monitoring
  Future<void> startBackgroundMonitoring() async {
    // Start main monitoring
    await _monitorService.startMonitoring();
    
    // Background cleanup setiap 24 jam
    _backgroundTimer = Timer.periodic(
      const Duration(hours: 24),
      (timer) => _monitorService.cleanup(),
    );
  }

  // Stop background monitoring
  Future<void> stopBackgroundMonitoring() async {
    await _monitorService.stopMonitoring();
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  // Handle app lifecycle changes
  void handleAppLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App kembali aktif, check reminders
        _monitorService.checkNow();
        break;
      case AppLifecycleState.paused:
        // App di-pause, tetap monitoring di background
        break;
      case AppLifecycleState.detached:
        // App ditutup, stop monitoring
        stopBackgroundMonitoring();
        break;
      case AppLifecycleState.inactive:
        // App tidak aktif, tetap monitoring
        break;
      case AppLifecycleState.hidden:
        // App tersembunyi, tetap monitoring
        break;
    }
  }
}

// Widget untuk menampilkan status monitoring
class ActivityMonitorStatus extends StatefulWidget {
  const ActivityMonitorStatus({super.key});

  @override
  State<ActivityMonitorStatus> createState() => _ActivityMonitorStatusState();
}

class _ActivityMonitorStatusState extends State<ActivityMonitorStatus> {
  final ActivityMonitorService _monitorService = ActivityMonitorService();
  bool _isMonitoring = false;
  DateTime? _lastCheck;

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    setState(() {
      _isMonitoring = _monitorService.isMonitoring;
      _lastCheck = _monitorService.lastActivityCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isMonitoring ? Icons.monitor_heart : Icons.monitor_heart_outlined,
                  color: _isMonitoring ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Activity Monitor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isMonitoring ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isMonitoring ? 'Aktif' : 'Nonaktif',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_lastCheck != null) ...[
              const SizedBox(height: 8),
              Text(
                'Terakhir diperiksa: ${_formatDateTime(_lastCheck!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isMonitoring ? null : _startMonitoring,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isMonitoring ? _stopMonitoring : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startMonitoring() async {
    await _monitorService.startMonitoring();
    _updateStatus();
  }

  Future<void> _stopMonitoring() async {
    await _monitorService.stopMonitoring();
    _updateStatus();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
