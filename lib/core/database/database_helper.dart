import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A Singleton class that manages the SQLite database connection and initialization.
/// This ensures only one database connection is open at a time across the entire app.
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Private database instance
  static Database? _database;

  // Private constructor
  DatabaseHelper._init();

  /// Getter for the database. If it doesn't exist, it initializes it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('betterme.db');
    return _database!;
  }

  /// Initializes the database at the device's standard directory.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Database version
      onCreate: _createDB, // Called if the database file doesn't exist
      onConfigure: _onConfigure, // Called before onCreate to set properties
    );
  }

  /// Configures database settings before creation.
  /// Here we enable Foreign Keys, which are disabled by default in SQLite.
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Executes the SQL scripts to create all tables and relationships.
  Future _createDB(Database db, int version) async {

    // 1. PROFILE TABLE
    // FIXED: Added the 'name' column to match the UI and Domain model.
    await db.execute('''
      CREATE TABLE profile (
        id_profile INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sex TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        birth_date TEXT NOT NULL
      )
    ''');

    // 2. WEEK_DAY TABLE
    await db.execute('''
      CREATE TABLE week_day (
        name TEXT PRIMARY KEY,
        is_weekend TEXT NOT NULL
      )
    ''');

    // 3. DIET TABLE
    // Contains a Foreign Key referencing the profile table.
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

    // 4. MEAL TABLE
    await db.execute('''
      CREATE TABLE meal (
        id_meal INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // 5. DIET_MEAL_DAY (Many-to-Many intermediary table)
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

    // 6. TRAINING TABLE
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

    // 7. EXERCISE TABLE
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

    // 8. TRAINING_EXERCISE_DAY (Many-to-Many intermediary table)
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

    // Seed the database with default days of the week upon creation
    await _insertDefaultDays(db);
  }

  /// Inserts the default 7 days of the week into the week_day table.
  /// This is required to satisfy the N:M relationships constraints.
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