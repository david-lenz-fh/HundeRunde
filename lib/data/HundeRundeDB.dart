
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HundeRundeDB{
  HundeRundeDB._();

  static final HundeRundeDB instance = HundeRundeDB._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hunderunde.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        
        await db.execute('''
          CREATE TABLE Dogs (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Walks (
            id TEXT PRIMARY KEY,
            dog_id TEXT NOT NULL,
            started_at TEXT NOT NULL,
            ended_at TEXT,
            distance_in_m REAL,
            route TEXT,
            comment TEXT,
            sync_status INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (dog_id)
              REFERENCES Dogs(id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
