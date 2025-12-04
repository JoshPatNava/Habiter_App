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
      'start_date': "${startDate.year.toString().padLeft(4, '0')}-"
                    "${startDate.month.toString().padLeft(2, '0')}-"
                    "${startDate.day.toString().padLeft(2, '0')}",
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
      startDate: _parseDate(map['start_date']),
      goalCount: map['goal_count'] == null
        ? null
        : int.tryParse(map['goal_count'].toString().trim()),
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

static DateTime _parseDate(dynamic raw) {
  if (raw == null) return DateTime.now();

  final s = raw.toString().trim();

  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
    final parts = s.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  return DateTime.parse(s);
}

}
