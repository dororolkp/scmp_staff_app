import 'database_backend.dart';
import 'database_backend_native.dart'
    if (dart.library.html) 'database_backend_web.dart';

class DatabaseService {
  final DatabaseBackend _backend = createDatabaseBackend();

  Future<void> initDb() => _backend.initDb();
  Future<void> close() => _backend.close();
  Future<String> getDatabasePath() => _backend.getDatabasePath();

  Future<void> saveToken({
    required int userId,
    required String email,
    required String token,
  }) async {
    await _backend.saveToken(userId: userId, email: email, token: token);
  }

  Future<String?> getToken() async {
    return _backend.getToken();
  }

  Future<Map<String, Object?>?> getSession() async {
    return _backend.getSession();
  }

  Future<void> clearToken() async {
    await _backend.clearToken();
  }

  Future<Map<String, Object?>?> getAuthUserByCredentials({
    required String email,
    required String password,
  }) {
    return _backend.getAuthUserByCredentials(email: email, password: password);
  }

  Future<int> getStaffCount() async {
    return _backend.getStaffCount();
  }

  Future<Map<String, Object?>?> getStaffListMeta() {
    return _backend.getStaffListMeta();
  }

  Future<void> saveStaffListMeta({
    required int page,
    required int perPage,
    required int total,
    required int totalPages,
  }) {
    return _backend.saveStaffListMeta(
      page: page,
      perPage: perPage,
      total: total,
      totalPages: totalPages,
    );
  }

  Future<void> upsertStaffRecords(List<Map<String, Object?>> staff) {
    return _backend.upsertStaffRecords(staff);
  }

  Future<List<Map<String, Object?>>> getStaffPage({
    required int page,
    required int pageSize,
  }) async {
    return _backend.getStaffPage(page: page, pageSize: pageSize);
  }

  Future<List<Map<String, Object?>>> getAllStaff() {
    return _backend.getAllStaff();
  }

  Future<Map<String, Object?>?> getStaffById(int id) {
    return _backend.getStaffById(id);
  }

  Future<int> createStaff(Map<String, Object?> staff) {
    return _backend.createStaff(staff);
  }

  Future<bool> updateStaff(Map<String, Object?> staff) {
    return _backend.updateStaff(staff);
  }

  Future<bool> deleteStaff(int id) {
    return _backend.deleteStaff(id);
  }
}
