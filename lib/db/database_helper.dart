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
    return openDatabase(path, 
                        version: 1,
                        onConfigure: (db) async {
                          await db.execute('PRAGMA foreign_keys = ON');
                        }, 
                        onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(''' 
    CREATE TABLE habits(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      frequency INTEGER NOT NULL,
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
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE (habit_id, date)
      )
    ''');
  }

  // Add habit
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all habits
  Future<List<Habit>> getHabits() async {
    final db = await database;
    final rows = await db.query('habits', orderBy: 'id DESC');
    return rows.map((map) => Habit.fromMap(map)).toList();
  }

  //update Habit
  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add habit log & update if exists
  Future<int> upsertHabitLog(HabitLog log) async {
    final db = await database;
    final day = DateTime(log.date.year, log.date.month, log.date.day).toIso8601String().substring(0,10);
    final map = log.toMap()..['date'] = day;
    final updated = await db.update(
      'habit_logs',
      map,
      where: 'habit_id = ? AND date = ?',
      whereArgs: [log.habitId, day],
    );

    if(updated == 0) {
      return db.insert('habit_logs', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return updated;
  }

  // Get logs for a habit
  Future<List<HabitLog>> getHabitLogs(int habitId, {DateTime? forDay}) async {
    final db = await database;

    if (forDay != null) {
      final day = DateTime(forDay.year, forDay.month, forDay.day)
          .toIso8601String()
          .substring(0, 10);
      final rows = await db.query(
        'habit_logs',
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, day],
        orderBy: 'date DESC',
      );
      return rows.map((m) => HabitLog.fromMap(m)).toList();
    }

    final rows = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return rows.map((m) => HabitLog.fromMap(m)).toList();
}


  // Delete habit
  Future<int> deleteHabit(int id) async {
    final db = await database;
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}
