class HabitLog {
  final int? id;
  final int habitId; // foreign key to Habit
  final String date; // the date this log refers to
  final bool completed; // whether the habit was completed on this date

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
  });

  // Convert HabitLog to Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'completed': completed ? 1 : 0,
    };
  }

  // Create HabitLog from Map (database)
  factory HabitLog.fromMap(Map<String, dynamic> map) => HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      date: map['date'].toString().trim(),
      completed: map['completed'] == 1,
  );
}
