import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scmp_staff_app/core/services/api_service.dart';
import 'package:scmp_staff_app/core/services/database_service.dart';
import 'package:scmp_staff_app/core/services/password_hash_service.dart';
import 'package:scmp_staff_app/repositories/auth_repository.dart';
import 'package:scmp_staff_app/repositories/staff_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Repository database CRUD', () {
    late DatabaseService databaseService;
    late ApiService apiService;
    late AuthRepository authRepository;
    late StaffRepository staffRepository;

    setUp(() async {
      apiService = ApiService();
      databaseService = DatabaseService();
      authRepository = AuthRepository(dbService: databaseService);
      staffRepository = StaffRepository(
        apiService: apiService,
        dbService: databaseService,
      );
      await databaseService.initDb();
      await databaseService.clearToken();
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('creates scmp_app.db in the repository directory', () async {
      final dbPath = await staffRepository.getDatabasePath();

      expect(dbPath.endsWith('scmp_app.db'), isTrue);
      expect(
        dbPath,
        contains('C:\\Users\\leekw\\Documents\\Flutter test SCMP\\scmp_staff_app'),
      );
      expect(File(dbPath).existsSync(), isTrue);
    });

    test('automatically seeds all tables with default data', () async {
      await authRepository.login('eve.holt@reqres.in', 'cityslicka');
      final token = await databaseService.getToken();
      final allStaff = await staffRepository.getAllStaff();

      expect(token, isNotNull);
      expect(token!.split('.').length, 3);
      expect(allStaff.length, greaterThanOrEqualTo(12));
      expect(allStaff.first.email, 'olivia.tan@company.com');
      expect(allStaff.first.firstName, 'Olivia');
      expect(allStaff.first.lastName, 'Tan');
    });

    test('creates the full schema and seeded config tables', () async {
      final dbPath = await staffRepository.getDatabasePath();
      await databaseService.close();

      final db = sqlite.sqlite3.open(dbPath);
      addTearDown(db.dispose);

      final tables = db
          .select(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name ASC",
          )
          .map((row) => row['name'] as String)
          .toList();

      expect(tables, contains('app_config'));
      expect(tables, contains('auth_users'));
      expect(tables, contains('session'));
      expect(tables, contains('staff'));
      expect(tables, contains('staff_list_meta'));

      final authUserCount = db.select(
        'SELECT COUNT(*) AS count FROM auth_users',
      );
      final appConfigCount = db.select(
        'SELECT COUNT(*) AS count FROM app_config',
      );
      final sessionCount = db.select(
        'SELECT COUNT(*) AS count FROM session',
      );
      final metaCount = db.select(
        'SELECT COUNT(*) AS count FROM staff_list_meta',
      );

      expect(authUserCount.first['count'], greaterThanOrEqualTo(2));
      expect(appConfigCount.first['count'], greaterThanOrEqualTo(5));
      expect(sessionCount.first['count'], 1);
      expect(metaCount.first['count'], 1);

      final authUser = db.select(
        'SELECT email, password FROM auth_users WHERE email = ?',
        ['eve.holt@reqres.in'],
      );
      expect(authUser, isNotEmpty);
      expect(authUser.first['password'], isNot('cityslicka'));
      expect(
        authUser.first['password'],
        PasswordHashService.hashPassword('cityslicka'),
      );
    });

    test('rejects protected staff access without a valid login token', () async {
      expect(
        () => staffRepository.getAllStaff(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unauthorized access'),
          ),
        ),
      );
    });

    test('can create, retrieve, update, and delete staff rows', () async {
      await authRepository.login('eve.holt@reqres.in', 'cityslicka');
      final created = await staffRepository.createStaff(
        email: 'crud.user@company.com',
        firstName: 'Crud',
        lastName: 'User',
        avatar: 'https://reqres.in/img/faces/13-image.jpg',
      );

      final fetched = await staffRepository.getStaffById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.email, 'crud.user@company.com');
      expect(fetched.firstName, 'Crud');

      final edited = await staffRepository.updateStaff(
        created.copyWith(
          email: 'updated.user@company.com',
          firstName: 'Updated',
          lastName: 'Member',
          avatar: 'https://reqres.in/img/faces/14-image.jpg',
        ),
      );
      expect(edited, isTrue);

      final fetchedAfterUpdate = await staffRepository.getStaffById(created.id);
      expect(fetchedAfterUpdate, isNotNull);
      expect(fetchedAfterUpdate!.email, 'updated.user@company.com');
      expect(fetchedAfterUpdate.firstName, 'Updated');
      expect(fetchedAfterUpdate.lastName, 'Member');

      final deleted = await staffRepository.deleteStaff(created.id);
      expect(deleted, isTrue);

      final fetchedAfterDelete = await staffRepository.getStaffById(created.id);
      expect(fetchedAfterDelete, isNull);
    });
  });
}
