abstract class DatabaseBackend {
  Future<void> initDb();
  Future<void> close();
  Future<String> getDatabasePath();
  Future<void> saveToken({
    required int userId,
    required String email,
    required String token,
  });
  Future<String?> getToken();
  Future<Map<String, Object?>?> getSession();
  Future<void> clearToken();
  Future<Map<String, Object?>?> getAuthUserByCredentials({
    required String email,
    required String password,
  });
  Future<int> getStaffCount();
  Future<Map<String, Object?>?> getStaffListMeta();
  Future<void> saveStaffListMeta({
    required int page,
    required int perPage,
    required int total,
    required int totalPages,
  });
  Future<void> upsertStaffRecords(List<Map<String, Object?>> staff);
  Future<List<Map<String, Object?>>> getStaffPage({
    required int page,
    required int pageSize,
  });
  Future<List<Map<String, Object?>>> getAllStaff();
  Future<Map<String, Object?>?> getStaffById(int id);
  Future<int> createStaff(Map<String, Object?> staff);
  Future<bool> updateStaff(Map<String, Object?> staff);
  Future<bool> deleteStaff(int id);
}
