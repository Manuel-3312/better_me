import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('betterme.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id_profile INTEGER PRIMARY KEY AUTOINCREMENT,
        sex TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        birth_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE week_day (
        name TEXT PRIMARY KEY,
        is_weekend TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE diet (
        id_diet INTEGER PRIMARY KEY AUTOINCREMENT,
        id_profile INTEGER NOT NULL,
        name TEXT NOT NULL,
        objective TEXT NOT NULL,
        allergies TEXT,
        additional_data TEXT,
        FOREIGN KEY (id_profile) REFERENCES profile (id_profile) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE meal (
        id_meal INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE diet_meal_day (
        id_diet INTEGER NOT NULL,
        id_meal INTEGER NOT NULL,
        day_name TEXT NOT NULL,
        PRIMARY KEY (id_diet, id_meal, day_name),
        FOREIGN KEY (id_diet) REFERENCES diet (id_diet) ON DELETE CASCADE,
        FOREIGN KEY (id_meal) REFERENCES meal (id_meal) ON DELETE CASCADE,
        FOREIGN KEY (day_name) REFERENCES week_day (name) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE training (
        id_training INTEGER PRIMARY KEY AUTOINCREMENT,
        id_profile INTEGER NOT NULL,
        name TEXT NOT NULL,
        objective TEXT NOT NULL,
        max_days INTEGER NOT NULL,
        max_time REAL NOT NULL,
        FOREIGN KEY (id_profile) REFERENCES profile (id_profile) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise (
        id_exercise INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps TEXT NOT NULL,
        rest TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE training_exercise_day (
        id_training INTEGER NOT NULL,
        id_exercise INTEGER NOT NULL,
        day_name TEXT NOT NULL,
        PRIMARY KEY (id_training, id_exercise, day_name),
        FOREIGN KEY (id_training) REFERENCES training (id_training) ON DELETE CASCADE,
        FOREIGN KEY (id_exercise) REFERENCES exercise (id_exercise) ON DELETE CASCADE,
        FOREIGN KEY (day_name) REFERENCES week_day (name) ON DELETE CASCADE
      )
    ''');

    await _insertDefaultDays(db);
  }

  Future _insertDefaultDays(Database db) async {
    final days = [
      {'name': 'Monday', 'is_weekend': 'N'},
      {'name': 'Tuesday', 'is_weekend': 'N'},
      {'name': 'Wednesday', 'is_weekend': 'N'},
      {'name': 'Thursday', 'is_weekend': 'N'},
      {'name': 'Friday', 'is_weekend': 'N'},
      {'name': 'Saturday', 'is_weekend': 'S'},
      {'name': 'Sunday', 'is_weekend': 'S'},
    ];
    for (var day in days) {
      await db.insert('week_day', day);
    }
  }
}