import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _morningEnabled = false;
  bool _eveningEnabled = false;

  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _morningEnabled = prefs.getBool('morning_reminder_enabled') ?? false;
      _eveningEnabled = prefs.getBool('evening_reminder_enabled') ?? false;

      _morningTime = TimeOfDay(
        hour: prefs.getInt('morning_reminder_hour') ?? 8,
        minute: prefs.getInt('morning_reminder_minute') ?? 0,
      );

      _eveningTime = TimeOfDay(
        hour: prefs.getInt('evening_reminder_hour') ?? 18,
        minute: prefs.getInt('evening_reminder_minute') ?? 0,
      );

      _isLoading = false;
    });
  }

  Future<void> _saveReminder({
    required bool isMorning,
    required bool enabled,
    required TimeOfDay time,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final id = isMorning ? 101 : 102;

    if (isMorning) {
      await prefs.setBool('morning_reminder_enabled', enabled);
      await prefs.setInt('morning_reminder_hour', time.hour);
      await prefs.setInt('morning_reminder_minute', time.minute);
    } else {
      await prefs.setBool('evening_reminder_enabled', enabled);
      await prefs.setInt('evening_reminder_hour', time.hour);
      await prefs.setInt('evening_reminder_minute', time.minute);
    }

    if (enabled) {
      await NotificationService.scheduleDailyReminder(
        id: id,
        hour: time.hour,
        minute: time.minute,
        title: isMorning ? 'أذكار الصباح 🌅' : 'أذكار المساء 🌙',
        body: isMorning
            ? 'ابدأ يومك بذكر الله، لا تنسَ أذكار الصباح.'
            : 'اختم يومك بذكر الله، لا تنسَ أذكار المساء.',
      );
    } else {
      await NotificationService.cancelReminder(id);
    }
  }

  Future<void> _changeTime(bool isMorning) async {
    final currentTime = isMorning ? _morningTime : _eveningTime;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    setState(() {
      if (isMorning) {
        _morningTime = selectedTime;
      } else {
        _eveningTime = selectedTime;
      }
    });

    final enabled = isMorning ? _morningEnabled : _eveningEnabled;

    await _saveReminder(
      isMorning: isMorning,
      enabled: enabled,
      time: selectedTime,
    );
  }

  Future<void> _toggleReminder(bool isMorning, bool value) async {
    setState(() {
      if (isMorning) {
        _morningEnabled = value;
      } else {
        _eveningEnabled = value;
      }
    });

    await _saveReminder(
      isMorning: isMorning,
      enabled: value,
      time: isMorning ? _morningTime : _eveningTime,
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool enabled,
    required TimeOfDay time,
    required VoidCallback onTimeTap,
    required ValueChanged<bool> onToggle,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(
                    icon,
                    color: color,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            const Divider(height: 30),
            InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'وقت التذكير',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time.format(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_left_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكيرات الأذكار'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'حافظ على وردك اليومي',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'حدد مواعيد تذكيرك بأذكار الصباح والمساء.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 25),
                _buildReminderCard(
                  title: 'أذكار الصباح',
                  subtitle: 'تذكير يومي بأذكار الصباح',
                  icon: Icons.wb_sunny_rounded,
                  color: Colors.orange,
                  enabled: _morningEnabled,
                  time: _morningTime,
                  onTimeTap: () => _changeTime(true),
                  onToggle: (value) => _toggleReminder(true, value),
                ),
                _buildReminderCard(
                  title: 'أذكار المساء',
                  subtitle: 'تذكير يومي بأذكار المساء',
                  icon: Icons.nights_stay_rounded,
                  color: Colors.indigo,
                  enabled: _eveningEnabled,
                  time: _eveningTime,
                  onTimeTap: () => _changeTime(false),
                  onToggle: (value) => _toggleReminder(false, value),
                ),
                const SizedBox(height: 10),
                Text(
                  'يمكنك تغيير المواعيد أو إيقاف التذكيرات في أي وقت.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}