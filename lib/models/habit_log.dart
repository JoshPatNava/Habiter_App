class HabitLog {
  int? id;
  int habitId; // foreign key to Habit
  DateTime date; // the date this log refers to
  bool completed; // whether the habit was completed on this date

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
  });

  // Convert HabitLog to Map (database)
  Map<String, dynamic> toMap() {
    final d = DateTime(date.year, date.month, date.day).toIso8601String().substring(0,10);
    return {
      'id': id,
      'habitId': habitId,
      'date': d,
      'completed': completed ? 1 : 0,
    };
  }

  // Create HabitLog from Map (database)
  factory HabitLog.fromMap(Map<String, dynamic> map) => HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      date: DateTime.parse(map['date']),
      completed: map['completed'] == 1,
  );
}
