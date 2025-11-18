import '../db/database_helper.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class HabitController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Get all habits from the database
  Future<List<Habit>> getAllHabits() async {
    return await _dbHelper.getHabits();
  }

  // Add a new habit
  Future<int> addHabit(Habit habit) async {
    return await _dbHelper.insertHabit(habit);
  }

  // Delete the habit
  Future<int> deleteHabit(int id) async {
    return await _dbHelper.deleteHabit(id);
  }

  // Update existing habit
  Future<int> updateHabit(Habit habit) async {
    return await _dbHelper.updateHabit(habit);
  }

  // Add habit log
  Future<int> addHabitLog(HabitLog log) async {
    return await _dbHelper.upsertHabitLog(log);
  }

  // get logs for specfied habit
  Future<List<HabitLog>> getHabitLogs(int habitId, {DateTime? forDay}) async {
    return await _dbHelper.getHabitLogs(habitId, forDay: forDay);
  }

  // count how many days a habit complete
  Future<int> getCompletionCount(int habitId) async {
    final logs = await getHabitLogs(habitId);
    return logs.where((log) => log.completed).length;
  }

  Future<bool> isCompletedOn(int habitId, DateTime day) async {
    final logs = await _dbHelper.getHabitLogs(habitId, forDay: day);
    return logs.any((log) => log.completed);
  }

   Future<void> toggleCompletion({
    required int habitId,
    required DateTime day,
    required bool completed,
  }) async {
    final log = HabitLog(habitId: habitId, date: day, completed: completed);
    await addHabitLog(log);
  }

   Future<Map<int, bool>> completionForAll(
    List<Habit> habits,
    DateTime day,
  ) async {
    final result = <int, bool>{};
    for (final h in habits) {
      if (h.id == null) continue;
      result[h.id!] = await isCompletedOn(h.id!, day);
    }
    return result;
  }
}
