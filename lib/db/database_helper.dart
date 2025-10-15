import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';

//Create and Initialize Database
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habit_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
    CREATE TABLE habits(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      frequency TEXT NOT NULL,
      start_date TEXT NOT NULL,
      goal_count INTEGER
    )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (habit_id) REFERENCES habits(id)
      )
    ''');
  }

// Add habit
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  // Get all habits
  Future<List<Habit>> getHabits() async {
    final db = await database;
    final result = await db.query('habits');
    return result.map((map) => Habit.fromMap(map)).toList();
  }

  //update Habit
  Future<int> updateHabit(Habit habit) async {
    final db = await database;
      return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  // Add habit log
  Future<int> insertHabitLog(HabitLog log) async {
    final db = await database;
    return await db.insert('habit_logs', log.toMap());
  }


  // Get logs for a habit
  Future<List<HabitLog>> getHabitLogs(int habitId) async {
    final db = await database;
    final result = await db.query('habit_logs', where: 'habit_id = ?', whereArgs: [habitId]);
    return result.map((map) => HabitLog.fromMap(map)).toList();  }

  // Update habit log (e.g., mark completed)
  Future<int> updateHabitLog(HabitLog log) async {
    final db = await database;
    return await db.update(
    'habit_logs',
    log.toMap(),
    where: 'id = ?',
    whereArgs: [log.id],
    );
  }

  // Delete habit
  Future<int> deleteHabit(int id) async {
    final db = await database;
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}