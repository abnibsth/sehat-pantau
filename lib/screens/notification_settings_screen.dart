import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _enableAll = true;
  bool _mealReminders = true;
  bool _movementReminders = true;
  bool _sleepReminders = true;
  bool _waterReminders = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableAll = prefs.getBool('notif_enable_all') ?? true;
      _mealReminders = prefs.getBool('notif_meal') ?? true;
      _movementReminders = prefs.getBool('notif_movement') ?? true;
      _sleepReminders = prefs.getBool('notif_sleep') ?? true;
      _waterReminders = prefs.getBool('notif_water') ?? true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_enable_all', _enableAll);
    await prefs.setBool('notif_meal', _mealReminders);
    await prefs.setBool('notif_movement', _movementReminders);
    await prefs.setBool('notif_sleep', _sleepReminders);
    await prefs.setBool('notif_water', _waterReminders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Aktifkan semua notifikasi'),
            value: _enableAll,
            onChanged: (v) {
              setState(() => _enableAll = v);
              _save();
            },
          ),
          const Divider(height: 1),
          _buildSwitch(
            title: 'Reminder Makan',
            value: _mealReminders,
            onChanged: (v) => setState(() { _mealReminders = v; _save(); }),
          ),
          _buildSwitch(
            title: 'Reminder Gerakan',
            value: _movementReminders,
            onChanged: (v) => setState(() { _movementReminders = v; _save(); }),
          ),
          _buildSwitch(
            title: 'Reminder Tidur',
            value: _sleepReminders,
            onChanged: (v) => setState(() { _sleepReminders = v; _save(); }),
          ),
          _buildSwitch(
            title: 'Reminder Minum Air',
            value: _waterReminders,
            onChanged: (v) => setState(() { _waterReminders = v; _save(); }),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Catatan: Pengaturan ini disimpan hanya di perangkat ini.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      title: Text(title),
      value: _enableAll ? value : false,
      onChanged: _enableAll ? onChanged : null,
      activeColor: Colors.blue,
    );
  }
}


