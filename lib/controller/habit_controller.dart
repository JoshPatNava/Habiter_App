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
    return await _dbHelper.insertHabitLog(log);
  }

  // get logs for specfied habit
  Future<List<HabitLog>> getHabitLogs(int habitId) async {
    return await _dbHelper.getHabitLogs(habitId);
  }

  // count how many days a habit complete
  Future<int> getCompletionCount(int habitId) async {
    final logs = await getHabitLogs(habitId);
    return logs.length;
  }
}
