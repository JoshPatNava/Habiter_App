class Habit {
  final int? id;
  final String name;
  final String? description;
  final String frequency;
  final DateTime startDate;
  final int? goalCount;

  Habit({
    this.id,
    required this.name,
    this.description,
    required this.frequency,
    required this.startDate,
    this.goalCount,
  });

// Convert Habit Obj to Map (database insertion/update)
Map<String, dynamic> toMap() {
  return {
    'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'start_date': startDate,
      'goal_count': goalCount,
    };
  }

// Create Habit Obj from Map (database retrieval)
factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      frequency: map['frequency'],
      startDate: map['start_date'],
      goalCount: map['goal_count'],
    );
  }
}
