import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';
import '../services/smart_reminder_service.dart';

class SmartReminderWidget extends StatefulWidget {
  const SmartReminderWidget({super.key});

  @override
  State<SmartReminderWidget> createState() => _SmartReminderWidgetState();
}

class _SmartReminderWidgetState extends State<SmartReminderWidget> {
  final SmartReminderService _reminderService = SmartReminderService();
  List<SmartReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminders = await _reminderService.getActiveReminders();
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_reminders.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tampilkan maksimal 2 reminder terbaru
    final displayReminders = _reminders.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.smart_toy,
              color: Colors.blue[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Reminder Cerdas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/smart_reminder');
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...displayReminders.map((reminder) => _buildReminderCard(reminder)).toList(),
      ],
    );
  }

  Widget _buildReminderCard(SmartReminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: reminder.priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showReminderDialog(reminder),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                reminder.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: reminder.priorityColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminderDialog(SmartReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(reminder.emoji),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                reminder.title,
                style: TextStyle(color: reminder.priorityColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: reminder.priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: reminder.priorityColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 16,
                    color: reminder.priorityColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Prioritas: ${reminder.priorityText}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: reminder.priorityColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _reminderService.markReminderTriggered(reminder.id);
              await _loadReminders();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder ditandai sebagai selesai'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}

class SmartReminderNotification extends StatelessWidget {
  final SmartReminder reminder;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const SmartReminderNotification({
    super.key,
    required this.reminder,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reminder.priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reminder.priorityColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: reminder.priorityColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                child: Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: reminder.priorityColor,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reminder.message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Nanti'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: reminder.priorityColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aksi'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
