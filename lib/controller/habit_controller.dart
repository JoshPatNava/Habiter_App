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
Future<List<HabitLog>> getHabitLogs(int habitId, {String ? forDay}) async {
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
    final logs = await getHabitLogs(habitId, forDay: dayString);
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
      final logs = await getHabitLogs(h.id!, forDay: dayString);
      result[h.id!] = logs.any((log) => log.completed);
    }

    return result;
  }

  Future<int> getTotalCompletions(int habitId) async {
    final logs = await getHabitLogs(habitId);
    return logs.where((log) => log.completed).length;
  }

  Future<int> getCurrentStreak(int habitId) async {
    final logs = await getHabitLogs(habitId);
   final completedLogs = logs
      .where((l) => l.completed)
      .toList()
    ..sort((a, b) => DateTime.parse(b.date.trim()).compareTo(DateTime.parse(a.date.trim())));

   if (completedLogs.isEmpty) return 0;

   int streak = 0;
    DateTime today = DateTime.now();
  DateTime expectedDay =
      DateTime(today.year, today.month, today.day); 

  for (final log in completedLogs) {
    final logDayDate = DateTime.parse(log.date.trim());
    final logDay =
        DateTime(logDayDate.year, logDayDate.month, logDayDate.day);

    if (logDay == expectedDay) {
      streak++;
      expectedDay = expectedDay.subtract(Duration(days: 1));
    } else if (logDay.isBefore(expectedDay)) {
      break;
    }
  }
    return streak;
  }

  Future<int> getBestStreak(int habitId) async {
    final logs = await getHabitLogs(habitId);
   final completedLogs = logs
      .where((l) => l.completed)
      .toList()
    ..sort((a, b) => DateTime.parse(a.date.trim()).compareTo(DateTime.parse(b.date.trim())));

  if (completedLogs.isEmpty) return 0;

  int current = 1;
  int best = 1;

  DateTime? prevDay;

  for (final log in completedLogs) {
    final logDate = DateTime.parse(log.date.trim());
    final logDay =
        DateTime(logDate.year, logDate.month, logDate.day);

    if (prevDay != null) {
      final diff = logDay.difference(prevDay).inDays;

      if (diff == 1) {
        current++;
      } else if (diff > 1) {
        current = 1;
      }

      if (current > best) best = current;
    }

    prevDay = logDay;
  }

    return best;
  }


  Future<double> getCompletionRate(Habit habit) async {
    final logs = await getHabitLogs(habit.id!);
    final completedLogs = logs.where((l) => l.completed).length;

    final start = DateTime(
      habit.startDate.year,
      habit.startDate.month,
      habit.startDate.day,
    );
    final today = DateTime.now();

    final days = today.difference(start).inDays + 1;
    if (days <= 0) return 0;

    return completedLogs / days;
  }

  Future<Map<String, dynamic>> getWeeklyGoalProgress(Habit habit) async {
  if (habit.frequency != 2) {
    return { "goal": null, "progress": null, "percentage": null };
  }

  final logs = await getHabitLogs(habit.id!);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday % 7));
  final weekEnd = weekStart.add(Duration(days: 6));

  final thisWeekLogs = logs.where((log) {
    final dt = DateTime.parse(log.date.trim());
    return dt.isAfter(weekStart.subtract(Duration(seconds: 1))) &&
           dt.isBefore(weekEnd.add(Duration(days: 1)));
  }).toList();

  final completed = thisWeekLogs.where((l) => l.completed).length;

  final goalCount = habit.goalCount ?? 0; // how many days per week

  return {
    "goal": goalCount,
    "progress": completed,
    "percentage": goalCount == 0 ? 0 : completed / goalCount,
  };
}

Future<List<bool>> getLast7DaysCompletion(int habitId) async {
  final logs = await getHabitLogs(habitId);

  final completedDays = logs
      .where((l) => l.completed)
      .map((l) => l.date.trim())
      .toSet();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  List<bool> last7 = [];

  for (int i = 6; i >= 0; i--) {
    final day = today.subtract(Duration(days: i));
    final formatted = "${day.year.toString().padLeft(4, '0')}-"
                      "${day.month.toString().padLeft(2, '0')}-"
                      "${day.day.toString().padLeft(2, '0')}";

    last7.add(completedDays.contains(formatted));
  }

  return last7;
}

Future<List<HabitLog>> getAllLogsForHabit(int habitId) async {
  return await getHabitLogs(habitId);  
}


}


