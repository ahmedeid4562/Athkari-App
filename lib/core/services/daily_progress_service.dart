import 'package:shared_preferences/shared_preferences.dart';

class DailyProgressService {
  static const String _dateKey = 'daily_progress_date';
  static const String _completedKey = 'daily_completed_azkar';

  Future<void> _checkNewDay() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';

    final savedDate = prefs.getString(_dateKey);

    if (savedDate != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setStringList(_completedKey, []);
    }
  }

  Future<void> markCompleted({
    required String categoryId,
    required int zekrId,
  }) async {
    await _checkNewDay();

    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedKey) ?? [];

    final key = '$categoryId:$zekrId';

    if (!completed.contains(key)) {
      completed.add(key);
      await prefs.setStringList(_completedKey, completed);
    }
  }

  Future<int> getCompletedCount() async {
    await _checkNewDay();

    final prefs = await SharedPreferences.getInstance();

    return (prefs.getStringList(_completedKey) ?? []).length;
  }
}
