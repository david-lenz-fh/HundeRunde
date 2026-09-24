import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(
      await getDatabasesPath(),
      'hunderunde.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE User ( 
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Dog (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE UserDog (
            userId INTEGER NOT NULL,
            dogId INTEGER NOT NULL,
            PRIMARY KEY (userId, dogId),
            FOREIGN KEY (userId) REFERENCES User(id),
            FOREIGN KEY (dogId) REFERENCES Dog(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE Walk (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dogId INTEGER NOT NULL,
            userId INTEGER NOT NULL,
            startedAt TEXT NOT NULL,
            endedAt TEXT,
            distance REAL,
            route TEXT,
            comment TEXT,
            FOREIGN KEY (dogId) REFERENCES Dog(id),
            FOREIGN KEY (userId) REFERENCES User(id)
          )
        ''');
      },
    );
  }
}