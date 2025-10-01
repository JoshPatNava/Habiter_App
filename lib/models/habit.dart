class Habit {
  int? id;
  String name;
  String? description;
  String frequency;
  DateTime startDate;
  int? goalCount;

  Habit({
    this.id,
    required this.name,
    this.description,
    required this.frequency,
    required this.startDate,
    this.goalCount,
  });
}

// Convert Habit Obj to Map (database insertion/update)

// Create Habit Obj from Map (database retrieval)