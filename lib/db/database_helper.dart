import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit.db');

    await deleteDatabase(path);

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        ByteData data = await rootBundle.load("assets/db/habit.db");
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        print("Error copying preloaded DB. Falling back to onCreate(): $e");
      }
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [log.habitId, log.date],
    );

  
    if (existing.isNotEmpty) {
      return await db.update(
        'habit_logs',
        log.toMap(),
        where: 'habit_id = ? AND date = ?',
        whereArgs: [log.habitId, log.date],
      );
    }
    return await db.insert('habit_logs', log.toMap());
  }

  // Get logs for a habit
  Future<List<HabitLog>> getHabitLogs(int habitId, {String? forDay}) async {
  final db = await database;

  if (forDay != null) {
    final rows = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, forDay],
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
