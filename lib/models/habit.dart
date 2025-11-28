class Habit {
  final int? id;
  final String name;
  final String? description;
  final int frequency; 
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
      'start_date': startDate.toIso8601String(),
      'goal_count': goalCount,
    };
  }

// Create Habit Obj from Map (database retrieval)
factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      frequency: map['frequency'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      goalCount: map['goal_count'] == null
        ? null
        : (map['goal_count'] as num).toInt(),
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    int? frequency,
    DateTime? startDate,
    int? goalCount,
  }) {
    return Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    frequency: frequency ?? this.frequency,
    startDate: startDate ?? this.startDate,
    goalCount: goalCount ?? this.goalCount,
  );
}
}
