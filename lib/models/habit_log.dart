class HabitLog {
  int? id;
  int habitId;             // foreign key to Habit
  DateTime date;           // the date this log refers to
  bool completed;          // whether the habit was completed on this date

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
  });

  // Convert HabitLog to Map (database)

  // Create HabitLog from Map (database)
}