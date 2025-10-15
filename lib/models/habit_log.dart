
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
Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completed':completed
    }; 
  }
  // Create HabitLog from Map (database)
   factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      date: map['date'],
      completed: map['completed'] == 1,
    );
  }
}
