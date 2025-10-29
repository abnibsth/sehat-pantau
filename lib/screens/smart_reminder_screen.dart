import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';
import '../services/smart_reminder_service.dart';

class SmartReminderScreen extends StatefulWidget {
  const SmartReminderScreen({super.key});

  @override
  State<SmartReminderScreen> createState() => _SmartReminderScreenState();
}

class _SmartReminderScreenState extends State<SmartReminderScreen> with TickerProviderStateMixin {
  final SmartReminderService _reminderService = SmartReminderService();
  List<SmartReminder> _reminders = [];
  ReminderSettings _settings = ReminderSettings();
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminders = await _reminderService.getActiveReminders();
      final settings = await _reminderService.getReminderSettings();
      
      setState(() {
        _reminders = reminders;
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reminders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Cerdas'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Reminder Aktif', icon: Icon(Icons.notifications_active)),
            Tab(text: 'Pengaturan', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRemindersTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildRemindersTab() {
    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada reminder aktif',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reminder akan muncul secara otomatis berdasarkan aktivitas Anda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(SmartReminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: reminder.priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  reminder.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: reminder.priorityColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPriorityChip(reminder.priority),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Dibuat: ${_formatDateTime(reminder.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _markAsDone(reminder),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Selesai'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _dismissReminder(reminder),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Tutup'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(ReminderPriority priority) {
    Color chipColor;
    String chipText;
    
    switch (priority) {
      case ReminderPriority.low:
        chipColor = Colors.green;
        chipText = 'Rendah';
        break;
      case ReminderPriority.medium:
        chipColor = Colors.orange;
        chipText = 'Sedang';
        break;
      case ReminderPriority.high:
        chipColor = Colors.red;
        chipText = 'Tinggi';
        break;
      case ReminderPriority.urgent:
        chipColor = Colors.purple;
        chipText = 'Mendesak';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Reminder',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          
          // Enable/Disable Reminders
          _buildSettingsSection(
            title: 'Aktifkan Reminder',
            children: [
              _buildSwitchTile(
                title: 'Reminder Makan',
                subtitle: 'Mengingatkan waktu makan berdasarkan pola makan',
                value: _settings.enableMealReminders,
                onChanged: (value) => _updateSetting('enableMealReminders', value),
              ),
              _buildSwitchTile(
                title: 'Reminder Gerakan',
                subtitle: 'Mengingatkan untuk bergerak setelah duduk lama',
                value: _settings.enableMovementReminders,
                onChanged: (value) => _updateSetting('enableMovementReminders', value),
              ),
              _buildSwitchTile(
                title: 'Reminder Tidur',
                subtitle: 'Mengingatkan waktu tidur optimal',
                value: _settings.enableSleepReminders,
                onChanged: (value) => _updateSetting('enableSleepReminders', value),
              ),
              _buildSwitchTile(
                title: 'Reminder Minum Air',
                subtitle: 'Mengingatkan untuk minum air secara teratur',
                value: _settings.enableWaterReminders,
                onChanged: (value) => _updateSetting('enableWaterReminders', value),
              ),
              _buildSwitchTile(
                title: 'Reminder Istirahat',
                subtitle: 'Mengingatkan untuk istirahat dari aktivitas',
                value: _settings.enableBreakReminders,
                onChanged: (value) => _updateSetting('enableBreakReminders', value),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Interval Settings
          _buildSettingsSection(
            title: 'Interval Reminder',
            children: [
              _buildSliderTile(
                title: 'Interval Makan',
                subtitle: '${_settings.mealIntervalHours} jam',
                value: _settings.mealIntervalHours.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                onChanged: (value) => _updateSetting('mealIntervalHours', value.toInt()),
              ),
              _buildSliderTile(
                title: 'Interval Gerakan',
                subtitle: '${_settings.movementIntervalMinutes} menit',
                value: _settings.movementIntervalMinutes.toDouble(),
                min: 30,
                max: 180,
                divisions: 15,
                onChanged: (value) => _updateSetting('movementIntervalMinutes', value.toInt()),
              ),
              _buildSliderTile(
                title: 'Interval Minum Air',
                subtitle: '${_settings.waterIntervalMinutes} menit',
                value: _settings.waterIntervalMinutes.toDouble(),
                min: 60,
                max: 300,
                divisions: 24,
                onChanged: (value) => _updateSetting('waterIntervalMinutes', value.toInt()),
              ),
              _buildSliderTile(
                title: 'Interval Istirahat',
                subtitle: '${_settings.breakIntervalMinutes} menit',
                value: _settings.breakIntervalMinutes.toDouble(),
                min: 30,
                max: 240,
                divisions: 21,
                onChanged: (value) => _updateSetting('breakIntervalMinutes', value.toInt()),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quiet Hours
          _buildSettingsSection(
            title: 'Jam Tenang',
            children: [
              ListTile(
                title: const Text('Jam Tenang'),
                subtitle: Text('${_settings.quietHours[0]} - ${_settings.quietHours[1]}'),
                trailing: const Icon(Icons.schedule),
                onTap: _showQuietHoursDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      switch (key) {
        case 'enableMealReminders':
          _settings = ReminderSettings(
            enableMealReminders: value,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'enableMovementReminders':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: value,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'enableSleepReminders':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: value,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'enableWaterReminders':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: value,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'enableBreakReminders':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: value,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'mealIntervalHours':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: value,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'movementIntervalMinutes':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: value,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'waterIntervalMinutes':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: value,
            breakIntervalMinutes: _settings.breakIntervalMinutes,
            quietHours: _settings.quietHours,
          );
          break;
        case 'breakIntervalMinutes':
          _settings = ReminderSettings(
            enableMealReminders: _settings.enableMealReminders,
            enableMovementReminders: _settings.enableMovementReminders,
            enableSleepReminders: _settings.enableSleepReminders,
            enableWaterReminders: _settings.enableWaterReminders,
            enableBreakReminders: _settings.enableBreakReminders,
            mealIntervalHours: _settings.mealIntervalHours,
            movementIntervalMinutes: _settings.movementIntervalMinutes,
            waterIntervalMinutes: _settings.waterIntervalMinutes,
            breakIntervalMinutes: value,
            quietHours: _settings.quietHours,
          );
          break;
      }
    });
    
    _reminderService.saveReminderSettings(_settings);
  }

  void _showQuietHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atur Jam Tenang'),
        content: const Text('Reminder tidak akan muncul pada jam tenang yang ditentukan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsDone(SmartReminder reminder) async {
    await _reminderService.markReminderTriggered(reminder.id);
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder ditandai sebagai selesai'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _dismissReminder(SmartReminder reminder) async {
    await _reminderService.deleteReminder(reminder.id);
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder dihapus'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
