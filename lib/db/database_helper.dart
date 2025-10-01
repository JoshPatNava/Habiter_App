import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//Create and Initialize Database
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

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
  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await database;
    return await db.insert('habits', habit);
  }

  // Get all habits
  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await database;
    return await db.query('habits');
  }

  // Add habit log
  Future<int> insertHabitLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert('habit_logs', log);
  }

  // Get logs for a habit
  Future<List<Map<String, dynamic>>> getHabitLogs(int habitId) async {
    final db = await database;
    return await db.query('habit_logs', where: 'habit_id = ?', whereArgs: [habitId]);
  }

  // Update habit log (e.g., mark completed)
  Future<int> updateHabitLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.update('habit_logs', log, where: 'id = ?', whereArgs: [log['id']]);
  }

  // Delete habit
  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}