import 'dart:io';

import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'database_backend.dart';
import 'password_hash_service.dart';

DatabaseBackend createDatabaseBackend() => NativeDatabaseBackend();

class NativeDatabaseBackend implements DatabaseBackend {
  sqlite.Database? _database;
  String? _dbPath;

  @override
  Future<void> initDb() async {
    if (_database != null) {
      return;
    }

    final dbPath = await getDatabasePath();
    final db = sqlite.sqlite3.open(dbPath);

    _database = db;
    _createTables();
    _migrateExistingSchema();
    await _seedTablesIfNeeded();
  }

  @override
  Future<void> close() async {
    _database?.dispose();
    _database = null;
  }

  @override
  Future<String> getDatabasePath() async {
    if (_dbPath != null) {
      return _dbPath!;
    }

    final repoRoot = _findRepositoryRoot();
    _dbPath = join(repoRoot, 'scmp_app.db');
    return _dbPath!;
  }

  @override
  Future<void> saveToken({
    required int userId,
    required String email,
    required String token,
  }) async {
    await initDb();
    _database!.execute(
      'UPDATE session SET user_id = ?, email = ?, token = ? WHERE id = ?',
      [userId, email, token, 1],
    );
  }

  @override
  Future<String?> getToken() async {
    await initDb();
    final result = _database!.select(
      'SELECT token FROM session WHERE id = ?',
      [1],
    );
    if (result.isEmpty) {
      return null;
    }
    return result.first['token'] as String?;
  }

  @override
  Future<Map<String, Object?>?> getSession() async {
    await initDb();
    final result = _database!.select(
      'SELECT id, user_id, email, token FROM session WHERE id = ?',
      [1],
    );
    if (result.isEmpty) {
      return null;
    }
    return Map<String, Object?>.from(result.first);
  }

  @override
  Future<void> clearToken() async {
    await initDb();
    _database!.execute(
      'UPDATE session SET user_id = ?, email = ?, token = ? WHERE id = ?',
      [null, 'eve.holt@reqres.in', null, 1],
    );
  }

  @override
  Future<Map<String, Object?>?> getAuthUserByCredentials({
    required String email,
    required String password,
  }) async {
    await initDb();
    final result = _database!.select(
      'SELECT id, email, password FROM auth_users WHERE email = ? AND password = ? LIMIT 1',
      [email.trim().toLowerCase(), password],
    );
    if (result.isEmpty) {
      return null;
    }
    return Map<String, Object?>.from(result.first);
  }

  @override
  Future<int> getStaffCount() async {
    await initDb();
    final result = _database!.select('SELECT COUNT(*) AS count FROM staff');
    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<List<Map<String, Object?>>> getStaffPage({
    required int page,
    required int pageSize,
  }) async {
    await initDb();
    final safePage = page < 1 ? 1 : page;
    final offset = (safePage - 1) * pageSize;
    final result = _database!.select(
      'SELECT id, email, first_name, last_name, avatar FROM staff ORDER BY id ASC LIMIT ? OFFSET ?',
      [pageSize, offset],
    );
    return result.map((row) => Map<String, Object?>.from(row)).toList();
  }

  @override
  Future<List<Map<String, Object?>>> getAllStaff() async {
    await initDb();
    final result = _database!.select(
      'SELECT id, email, first_name, last_name, avatar FROM staff ORDER BY id ASC',
    );
    return result.map((row) => Map<String, Object?>.from(row)).toList();
  }

  @override
  Future<Map<String, Object?>?> getStaffById(int id) async {
    await initDb();
    final result = _database!.select(
      'SELECT id, email, first_name, last_name, avatar FROM staff WHERE id = ?',
      [id],
    );
    if (result.isEmpty) {
      return null;
    }
    return Map<String, Object?>.from(result.first);
  }

  @override
  Future<int> createStaff(Map<String, Object?> staff) async {
    await initDb();
    _database!.execute(
      'INSERT INTO staff (email, first_name, last_name, avatar) VALUES (?, ?, ?, ?)',
      [
        staff['email'],
        staff['first_name'],
        staff['last_name'],
        staff['avatar'],
      ],
    );

    final inserted = _database!.select('SELECT last_insert_rowid() AS id');
    await _syncStaffListMetaWithCount();
    return inserted.first['id'] as int;
  }

  @override
  Future<bool> updateStaff(Map<String, Object?> staff) async {
    await initDb();
    _database!.execute(
      'UPDATE staff SET email = ?, first_name = ?, last_name = ?, avatar = ? WHERE id = ?',
      [
        staff['email'],
        staff['first_name'],
        staff['last_name'],
        staff['avatar'],
        staff['id'],
      ],
    );
    return _database!.updatedRows > 0;
  }

  @override
  Future<bool> deleteStaff(int id) async {
    await initDb();
    _database!.execute('DELETE FROM staff WHERE id = ?', [id]);
    final deleted = _database!.updatedRows > 0;
    if (deleted) {
      await _syncStaffListMetaWithCount();
    }
    return deleted;
  }

  void _createTables() {
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS staff (
        id INTEGER PRIMARY KEY,
        email TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        avatar TEXT NOT NULL
      )
    ''');
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER,
        email TEXT,
        token TEXT
      )
    ''');
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS auth_users (
        id INTEGER PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS staff_list_meta (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        page INTEGER NOT NULL,
        per_page INTEGER NOT NULL,
        total INTEGER NOT NULL,
        total_pages INTEGER NOT NULL,
        last_synced_at TEXT
      )
    ''');
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS app_config (
        config_key TEXT PRIMARY KEY,
        config_value TEXT NOT NULL
      )
    ''');
  }

  void _migrateExistingSchema() {
    _ensureColumnExists(
      tableName: 'session',
      columnName: 'user_id',
      definition: 'INTEGER',
    );
    _ensureColumnExists(
      tableName: 'session',
      columnName: 'email',
      definition: 'TEXT',
    );
  }

  void _ensureColumnExists({
    required String tableName,
    required String columnName,
    required String definition,
  }) {
    final columns = _database!.select('PRAGMA table_info($tableName)');
    final exists = columns.any((row) => row['name'] == columnName);
    if (!exists) {
      _database!.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnName $definition',
      );
    }
  }

  Future<void> _syncStaffListMetaWithCount() async {
    final count = await getStaffCount();
    final existing = await getStaffListMeta();
    final perPage = (existing?['per_page'] as int?) ?? 6;
    final totalPages = count == 0 ? 1 : (count / perPage).ceil();
    await saveStaffListMeta(
      page: 1,
      perPage: perPage,
      total: count,
      totalPages: totalPages,
    );
  }

  Future<void> _seedSessionIfNeeded() async {
    final result = _database!.select(
      'SELECT id, user_id, email, token FROM session WHERE id = ?',
      [1],
    );
    if (result.isNotEmpty) {
      return;
    }

    _database!.execute(
      'INSERT INTO session (id, user_id, email, token) VALUES (?, ?, ?, ?)',
      [1, null, 'eve.holt@reqres.in', null],
    );
  }

  Future<void> _seedAuthUsersIfNeeded() async {
    for (final row in _dummyAuthUsers) {
      _database!.execute(
        'INSERT OR REPLACE INTO auth_users (id, email, password) VALUES (?, ?, ?)',
        [
          row['id'],
          row['email'],
          row['password'],
        ],
      );
    }
  }

  Future<void> _seedStaffIfNeeded() async {
    final count = await getStaffCount();
    if (count > 0) {
      return;
    }

    for (final row in _dummyStaff) {
      _database!.execute(
        'INSERT OR REPLACE INTO staff (id, email, first_name, last_name, avatar) VALUES (?, ?, ?, ?, ?)',
        [
          row['id'],
          row['email'],
          row['first_name'],
          row['last_name'],
          row['avatar'],
        ],
      );
    }

    await saveStaffListMeta(
      page: 1,
      perPage: 6,
      total: _dummyStaff.length,
      totalPages: 2,
    );
  }

  Future<void> _seedAppConfigIfNeeded() async {
    final configRows = [
      {'config_key': 'db_name', 'config_value': 'scmp_app.db'},
      {'config_key': 'api_application_name', 'config_value': 'ReqRes Demo API'},
      {'config_key': 'api_base_url', 'config_value': 'https://reqres.in/api'},
      {'config_key': 'auth_mode', 'config_value': 'sqlite_jwt'},
      {
        'config_key': 'api_application_base_url',
        'config_value': 'https://reqres.in/api',
      },
      {
        'config_key': 'repo_url',
        'config_value': 'https://github.com/dororolkp/scmp_staff_app',
      },
      {'config_key': 'architecture', 'config_value': 'MVVM'},
      {'config_key': 'agentic_tools', 'config_value': 'Trae AI Agent'},
    ];

    for (final row in configRows) {
      _database!.execute(
        'INSERT OR REPLACE INTO app_config (config_key, config_value) VALUES (?, ?)',
        [row['config_key'], row['config_value']],
      );
    }
  }

  Future<void> _seedTablesIfNeeded() async {
    await _seedSessionIfNeeded();
    await _seedAuthUsersIfNeeded();
    await _seedAppConfigIfNeeded();
    await _seedStaffIfNeeded();
  }

  @override
  Future<Map<String, Object?>?> getStaffListMeta() async {
    await initDb();
    final result = _database!.select(
      'SELECT page, per_page, total, total_pages, last_synced_at FROM staff_list_meta WHERE id = ?',
      [1],
    );
    if (result.isEmpty) {
      return null;
    }
    return Map<String, Object?>.from(result.first);
  }

  @override
  Future<void> saveStaffListMeta({
    required int page,
    required int perPage,
    required int total,
    required int totalPages,
  }) async {
    await initDb();
    _database!.execute(
      '''
      INSERT OR REPLACE INTO staff_list_meta (
        id, page, per_page, total, total_pages, last_synced_at
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [1, page, perPage, total, totalPages, DateTime.now().toIso8601String()],
    );
  }

  @override
  Future<void> upsertStaffRecords(List<Map<String, Object?>> staff) async {
    await initDb();
    for (final row in staff) {
      _database!.execute(
        '''
        INSERT OR REPLACE INTO staff (id, email, first_name, last_name, avatar)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [
          row['id'],
          row['email'],
          row['first_name'],
          row['last_name'],
          row['avatar'],
        ],
      );
    }
  }

  String _findRepositoryRoot() {
    var current = Directory.current.absolute;
    while (true) {
      final pubspec = File(join(current.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        return current.path;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        return Directory.current.absolute.path;
      }
      current = parent;
    }
  }
}

final List<Map<String, Object?>> _dummyStaff = [
  {
    'id': 1,
    'email': 'olivia.tan@company.com',
    'first_name': 'Olivia',
    'last_name': 'Tan',
    'avatar': 'https://reqres.in/img/faces/1-image.jpg',
  },
  {
    'id': 2,
    'email': 'liam.ong@company.com',
    'first_name': 'Liam',
    'last_name': 'Ong',
    'avatar': 'https://reqres.in/img/faces/2-image.jpg',
  },
  {
    'id': 3,
    'email': 'sophia.lim@company.com',
    'first_name': 'Sophia',
    'last_name': 'Lim',
    'avatar': 'https://reqres.in/img/faces/3-image.jpg',
  },
  {
    'id': 4,
    'email': 'noah.ng@company.com',
    'first_name': 'Noah',
    'last_name': 'Ng',
    'avatar': 'https://reqres.in/img/faces/4-image.jpg',
  },
  {
    'id': 5,
    'email': 'ava.lee@company.com',
    'first_name': 'Ava',
    'last_name': 'Lee',
    'avatar': 'https://reqres.in/img/faces/5-image.jpg',
  },
  {
    'id': 6,
    'email': 'ethan.teo@company.com',
    'first_name': 'Ethan',
    'last_name': 'Teo',
    'avatar': 'https://reqres.in/img/faces/6-image.jpg',
  },
  {
    'id': 7,
    'email': 'mia.goh@company.com',
    'first_name': 'Mia',
    'last_name': 'Goh',
    'avatar': 'https://reqres.in/img/faces/7-image.jpg',
  },
  {
    'id': 8,
    'email': 'jacob.chan@company.com',
    'first_name': 'Jacob',
    'last_name': 'Chan',
    'avatar': 'https://reqres.in/img/faces/8-image.jpg',
  },
  {
    'id': 9,
    'email': 'amelia.koh@company.com',
    'first_name': 'Amelia',
    'last_name': 'Koh',
    'avatar': 'https://reqres.in/img/faces/9-image.jpg',
  },
  {
    'id': 10,
    'email': 'lucas.yap@company.com',
    'first_name': 'Lucas',
    'last_name': 'Yap',
    'avatar': 'https://reqres.in/img/faces/10-image.jpg',
  },
  {
    'id': 11,
    'email': 'charlotte.toh@company.com',
    'first_name': 'Charlotte',
    'last_name': 'Toh',
    'avatar': 'https://reqres.in/img/faces/11-image.jpg',
  },
  {
    'id': 12,
    'email': 'henry.woo@company.com',
    'first_name': 'Henry',
    'last_name': 'Woo',
    'avatar': 'https://reqres.in/img/faces/12-image.jpg',
  },
];

final List<Map<String, Object?>> _dummyAuthUsers = [
  {
    'id': 1,
    'email': 'eve.holt@reqres.in',
    'password': PasswordHashService.hashPassword('cityslicka'),
  },
  {
    'id': 2,
    'email': 'john.doe@company.com',
    'password': PasswordHashService.hashPassword('abc123'),
  },
];
