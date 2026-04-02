import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton helper class for managing the local SQLite database.
/// Handles initialization, configuration, creation, and upgrading of tables.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('betterme_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE progress_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_profile INTEGER NOT NULL,
          entry_date TEXT NOT NULL,
          weight REAL NOT NULL,
          photo_paths TEXT NOT NULL,
          FOREIGN KEY (id_profile) REFERENCES profile (id_profile) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id_profile INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sex TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        birth_date TEXT NOT NULL,
        active_diet_id INTEGER,
        active_training_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE week_day (
        name TEXT PRIMARY KEY,
        is_weekend TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE local_exercises (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        category_name TEXT NOT NULL,
        main_muscle_id INTEGER,
        exercise_image_url TEXT
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
        generated_content TEXT,
        FOREIGN KEY (id_profile) REFERENCES profile (id_profile) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE training_day (
        id_training_day INTEGER PRIMARY KEY AUTOINCREMENT,
        id_training INTEGER NOT NULL,
        day_number INTEGER NOT NULL,
        focus TEXT,
        FOREIGN KEY (id_training) REFERENCES training (id_training) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise (
        id_exercise INTEGER PRIMARY KEY AUTOINCREMENT,
        id_training_day INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL, 
        sets INTEGER NOT NULL,
        reps TEXT NOT NULL,
        rest_seconds INTEGER NOT NULL,
        tips TEXT,
        FOREIGN KEY (id_training_day) REFERENCES training_day (id_training_day) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES local_exercises (id) ON DELETE CASCADE
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
        generated_content TEXT,
        FOREIGN KEY (id_profile) REFERENCES profile (id_profile) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE weight_history (
        id_weight INTEGER PRIMARY KEY AUTOINCREMENT,
        id_profile INTEGER NOT NULL,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (id_profile) REFERENCES profile (id_profile) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE progress_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_profile INTEGER NOT NULL,
        entry_date TEXT NOT NULL,
        weight REAL NOT NULL,
        photo_paths TEXT NOT NULL,
        FOREIGN KEY (id_profile) REFERENCES profile (id_profile) ON DELETE CASCADE
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