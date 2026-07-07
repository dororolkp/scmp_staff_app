import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'scmp_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE staff (
            id INTEGER PRIMARY KEY,
            email TEXT,
            first_name TEXT,
            last_name TEXT,
            avatar TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE session (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            token TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveToken(String token) async {
    final db = await database;
    await db.insert(
      'session',
      {'id': 1, 'token': token},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getToken() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('session', where: 'id = 1');
    if (maps.isNotEmpty) {
      return maps.first['token'] as String;
    }
    return null;
  }

  Future<void> clearToken() async {
    final db = await database;
    await db.delete('session', where: 'id = 1');
  }
}
