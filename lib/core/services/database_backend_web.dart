import 'dart:convert';
import 'dart:html' as html;

import 'database_backend.dart';
import 'password_hash_service.dart';

DatabaseBackend createDatabaseBackend() => WebDatabaseBackend();

class WebDatabaseBackend implements DatabaseBackend {
  static const String _dbName = 'scmp_app.db';
  static const String _sessionKey = 'scmp_app.db:session';
  static const String _authUsersKey = 'scmp_app.db:auth_users';
  static const String _staffKey = 'scmp_app.db:staff';
  static const String _staffMetaKey = 'scmp_app.db:staff_list_meta';
  static const String _configKey = 'scmp_app.db:app_config';

  bool _initialized = false;
  Map<String, Object?> _session = {};
  final List<Map<String, Object?>> _authUsers = [];
  Map<String, Object?> _staffMeta = {};
  Map<String, String> _appConfig = {};
  final List<Map<String, Object?>> _staff = [];

  @override
  Future<void> initDb() async {
    if (_initialized) {
      return;
    }

    _loadPersistedState();
    if (_session.isEmpty) {
      _session = {
        'id': 1,
        'user_id': null,
        'email': 'eve.holt@reqres.in',
        'token': null,
      };
    }
    if (_authUsers.isEmpty) {
      _authUsers.addAll(
        _dummyAuthUsers.map((row) => Map<String, Object?>.from(row)),
      );
    } else {
      for (final row in _dummyAuthUsers) {
        final index = _authUsers.indexWhere((item) => item['id'] == row['id']);
        if (index == -1) {
          _authUsers.add(Map<String, Object?>.from(row));
        } else {
          _authUsers[index] = Map<String, Object?>.from(row);
        }
      }
    }
    if (_staffMeta.isEmpty) {
      _staffMeta = {
        'page': 1,
        'per_page': 6,
        'total': _dummyStaff.length,
        'total_pages': 2,
        'last_synced_at': DateTime.now().toIso8601String(),
      };
    }
    _appConfig = {
      'db_name': _dbName,
      'api_application_name': 'ReqRes Demo API',
      'api_base_url': 'https://reqres.in/api',
      'auth_mode': 'sqlite_jwt',
      'api_application_base_url': 'https://reqres.in/api',
      'repo_url': 'https://github.com/dororolkp/scmp_staff_app',
      'architecture': 'MVVM',
      'agentic_tools': 'Trae AI Agent',
      ..._appConfig,
    };
    if (_staff.isEmpty) {
      _staff.addAll(_dummyStaff.map((row) => Map<String, Object?>.from(row)));
    }

    _persistState();
    _initialized = true;
  }

  @override
  Future<void> close() async {}

  @override
  Future<String> getDatabasePath() async {
    await initDb();
    return _dbName;
  }

  @override
  Future<void> saveToken({
    required int userId,
    required String email,
    required String token,
  }) async {
    await initDb();
    _session['user_id'] = userId;
    _session['email'] = email;
    _session['token'] = token;
    _persistState();
  }

  @override
  Future<String?> getToken() async {
    await initDb();
    return _session['token'] as String?;
  }

  @override
  Future<Map<String, Object?>?> getSession() async {
    await initDb();
    return Map<String, Object?>.from(_session);
  }

  @override
  Future<void> clearToken() async {
    await initDb();
    _session['user_id'] = null;
    _session['email'] = 'eve.holt@reqres.in';
    _session['token'] = null;
    _persistState();
  }

  @override
  Future<Map<String, Object?>?> getAuthUserByCredentials({
    required String email,
    required String password,
  }) async {
    await initDb();
    for (final row in _authUsers) {
      if (row['email'] == email.trim().toLowerCase() &&
          row['password'] == password) {
        return Map<String, Object?>.from(row);
      }
    }
    return null;
  }

  @override
  Future<int> getStaffCount() async {
    await initDb();
    return _staff.length;
  }

  @override
  Future<Map<String, Object?>?> getStaffListMeta() async {
    await initDb();
    return Map<String, Object?>.from(_staffMeta);
  }

  @override
  Future<void> saveStaffListMeta({
    required int page,
    required int perPage,
    required int total,
    required int totalPages,
  }) async {
    await initDb();
    _staffMeta = {
      'page': page,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
      'last_synced_at': DateTime.now().toIso8601String(),
    };
    _persistState();
  }

  @override
  Future<void> upsertStaffRecords(List<Map<String, Object?>> staff) async {
    await initDb();
    for (final row in staff) {
      final index = _staff.indexWhere((item) => item['id'] == row['id']);
      if (index == -1) {
        _staff.add(Map<String, Object?>.from(row));
      } else {
        _staff[index] = Map<String, Object?>.from(row);
      }
    }
    _staff.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    _persistState();
  }

  @override
  Future<List<Map<String, Object?>>> getStaffPage({
    required int page,
    required int pageSize,
  }) async {
    await initDb();
    final safePage = page < 1 ? 1 : page;
    final offset = (safePage - 1) * pageSize;
    if (offset >= _staff.length) {
      return [];
    }
    final end = (offset + pageSize).clamp(0, _staff.length);
    return _staff
        .sublist(offset, end)
        .map((row) => Map<String, Object?>.from(row))
        .toList();
  }

  @override
  Future<List<Map<String, Object?>>> getAllStaff() async {
    await initDb();
    return _staff.map((row) => Map<String, Object?>.from(row)).toList();
  }

  @override
  Future<Map<String, Object?>?> getStaffById(int id) async {
    await initDb();
    for (final row in _staff) {
      if (row['id'] == id) {
        return Map<String, Object?>.from(row);
      }
    }
    return null;
  }

  @override
  Future<int> createStaff(Map<String, Object?> staff) async {
    await initDb();
    final nextId = _staff.isEmpty
        ? 1
        : _staff
                .map((row) => row['id'] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final newStaff = Map<String, Object?>.from(staff)..['id'] = nextId;
    _staff.add(newStaff);
    await _syncStaffMetaWithCount();
    _persistState();
    return nextId;
  }

  @override
  Future<bool> updateStaff(Map<String, Object?> staff) async {
    await initDb();
    final id = staff['id'];
    for (var i = 0; i < _staff.length; i++) {
      if (_staff[i]['id'] == id) {
        _staff[i] = Map<String, Object?>.from(staff);
        _persistState();
        return true;
      }
    }
    return false;
  }

  @override
  Future<bool> deleteStaff(int id) async {
    await initDb();
    final originalLength = _staff.length;
    _staff.removeWhere((row) => row['id'] == id);
    final deleted = _staff.length != originalLength;
    if (deleted) {
      await _syncStaffMetaWithCount();
      _persistState();
    }
    return deleted;
  }

  void _loadPersistedState() {
    final sessionJson = html.window.localStorage[_sessionKey];
    final authUsersJson = html.window.localStorage[_authUsersKey];
    final staffJson = html.window.localStorage[_staffKey];
    final staffMetaJson = html.window.localStorage[_staffMetaKey];
    final configJson = html.window.localStorage[_configKey];

    if (sessionJson != null && sessionJson.isNotEmpty) {
      _session = Map<String, Object?>.from(jsonDecode(sessionJson) as Map);
    }
    if (authUsersJson != null && authUsersJson.isNotEmpty) {
      final decoded = jsonDecode(authUsersJson) as List<dynamic>;
      _authUsers
        ..clear()
        ..addAll(
          decoded.map(
            (row) => Map<String, Object?>.from(row as Map),
          ),
        );
    }
    if (staffJson != null && staffJson.isNotEmpty) {
      final decoded = jsonDecode(staffJson) as List<dynamic>;
      _staff
        ..clear()
        ..addAll(
          decoded.map(
            (row) => Map<String, Object?>.from(row as Map),
          ),
        );
    }
    if (staffMetaJson != null && staffMetaJson.isNotEmpty) {
      _staffMeta = Map<String, Object?>.from(jsonDecode(staffMetaJson) as Map);
    }
    if (configJson != null && configJson.isNotEmpty) {
      _appConfig = Map<String, String>.from(jsonDecode(configJson) as Map);
    }
  }

  void _persistState() {
    html.window.localStorage[_sessionKey] = jsonEncode(_session);
    html.window.localStorage[_authUsersKey] = jsonEncode(_authUsers);
    html.window.localStorage[_staffKey] = jsonEncode(_staff);
    html.window.localStorage[_staffMetaKey] = jsonEncode(_staffMeta);
    html.window.localStorage[_configKey] = jsonEncode(_appConfig);
  }

  Future<void> _syncStaffMetaWithCount() async {
    final count = _staff.length;
    final perPage = (_staffMeta['per_page'] as int?) ?? 6;
    final totalPages = count == 0 ? 1 : (count / perPage).ceil();
    _staffMeta = {
      'page': 1,
      'per_page': perPage,
      'total': count,
      'total_pages': totalPages,
      'last_synced_at': DateTime.now().toIso8601String(),
    };
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
