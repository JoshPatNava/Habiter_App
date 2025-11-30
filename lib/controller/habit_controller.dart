import '../db/database_helper.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'package:intl/intl.dart';


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
Future<List<HabitLog>> getHabitLogs(int habitId, {String? forDay}) async {
  if (forDay == null) {
    return await _dbHelper.getHabitLogs(habitId);
  }

  return await _dbHelper.getHabitLogs(habitId, forDay: forDay);
}


  // count how many days a habit complete
  Future<int> getCompletionCount(int habitId) async {
    final logs = await getHabitLogs(habitId);
    return logs.where((log) => log.completed).length;
  }

  Future<bool> isCompletedOn(int habitId, DateTime day) async {
    final dayString = DateFormat('yyyy-MM-dd').format(day);
    final logs = await _dbHelper.getHabitLogs(habitId, forDay: dayString);
    return logs.any((log) => log.completed);
  }

   Future<void> toggleCompletion({
    required int habitId,
    required DateTime day,
    required bool completed,
  }) async {
    final dayString = DateFormat('yyyy-MM-dd').format(day);

     final log = HabitLog(
      habitId: habitId,
      date: dayString,    
      completed: completed,
     );
    await _dbHelper.upsertHabitLog(log);
  }

   Future<Map<int, bool>> completionForAll(
    List<Habit> habits,
    DateTime day,
  ) async {
    final result = <int, bool>{};

    final dayString = DateFormat('yyyy-MM-dd').format(day);

    for (final h in habits) {
      if (h.id == null) continue;
      final logs = await _dbHelper.getHabitLogs(h.id!, forDay: dayString);
      result[h.id!] = logs.any((log) => log.completed);
    }

    return result;
  }

  Future<int> getTotalCompletions(int habitId) async {
    final logs = await _dbHelper.getHabitLogs(habitId);
    return logs.where((log) => log.completed == 1).length;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<int> getCurrentStreak(int habitId) async {
    final logs = await _dbHelper.getHabitLogs(habitId);
    logs.sort((a, b) => b.date.compareTo(a.date)); 

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime expectedDate = DateTime(today.year, today.month, today.day);

    for (var log in logs) {
      DateTime logDate = DateTime.parse(log.date);

      if (log.completed == 1 && _isSameDay(logDate, expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(Duration(days: 1));
      } else if (logDate.isBefore(expectedDate)) {
        break;
      }
    }

    return streak;
  }

  Future<int> getBestStreak(int habitId) async {
    final logs = await _dbHelper.getHabitLogs(habitId);
    logs.sort((a, b) => a.date.compareTo(b.date)); 

    int best = 0;
    int current = 0;
    DateTime? previousDay;

    for (var log in logs) {
      DateTime logDate = DateTime.parse(log.date);

      if (log.completed == 1) {
        if (previousDay != null &&
            logDate.difference(previousDay!).inDays == 1) {
          current++;
        } else {
          current = 1;
        }
        best = current > best ? current : best;
      }

      previousDay = logDate;
    }

    return best;
  }


}


