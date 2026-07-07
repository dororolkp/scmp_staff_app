import 'package:scmp_staff_app/core/services/api_service.dart';
import 'package:scmp_staff_app/core/services/database_service.dart';
import 'package:scmp_staff_app/core/services/jwt_token_service.dart';
import 'package:scmp_staff_app/models/staff.dart';

class StaffResponse {
  final List<Staff> data;
  final int totalPages;
  final int page;

  StaffResponse({required this.data, required this.totalPages, required this.page});
}

class StaffRepository {
  final ApiService apiService;
  final DatabaseService dbService;
  static const int _pageSize = 6;

  StaffRepository({required this.apiService, required this.dbService});

  Future<StaffResponse> getStaffList(int page) async {
    await _ensureAuthorized();
    final safePage = page < 1 ? 1 : page;
    try {
      final response = await apiService.get(
        '/users',
        queryParameters: {'page': safePage},
      );
      final data = response.data;
      if (data is! Map) {
        throw Exception('Unexpected staff API response');
      }

      final rawData = (data['data'] as List<dynamic>? ?? const [])
          .map((row) => Map<String, Object?>.from(row as Map))
          .toList();
      final currentPage = (data['page'] as int?) ?? safePage;
      final perPage = (data['per_page'] as int?) ?? _pageSize;
      final total = (data['total'] as int?) ?? rawData.length;
      final totalPages = (data['total_pages'] as int?) ?? 1;

      await dbService.upsertStaffRecords(rawData);
      await dbService.saveStaffListMeta(
        page: currentPage,
        perPage: perPage,
        total: total,
        totalPages: totalPages,
      );

      return StaffResponse(
        data: rawData.map(Staff.fromJson).toList(),
        totalPages: totalPages,
        page: currentPage,
      );
    } catch (_) {
      final maps = await dbService.getStaffPage(
        page: safePage,
        pageSize: _pageSize,
      );
      if (maps.isEmpty) {
        rethrow;
      }

      final meta = await dbService.getStaffListMeta();
      final totalPages = (meta?['total_pages'] as int?) ??
          ((await dbService.getStaffCount()) / _pageSize).ceil();
      return StaffResponse(
        data: maps.map(Staff.fromJson).toList(),
        totalPages: totalPages,
        page: safePage,
      );
    }
  }

  Future<String?> getToken() async {
    final session = await dbService.getSession();
    final token = session?['token'] as String?;
    if (token == null || token.isEmpty) {
      return null;
    }

    final payload = JwtTokenService.verifyToken(token);
    final sessionEmail = session?['email'] as String?;
    if (payload == null || sessionEmail == null || payload['email'] != sessionEmail) {
      await dbService.clearToken();
      return null;
    }
    return token;
  }

  Future<String> getDatabasePath() {
    return dbService.getDatabasePath();
  }

  Future<List<Staff>> getAllStaff() async {
    await _ensureAuthorized();
    final maps = await dbService.getAllStaff();
    return maps.map(Staff.fromJson).toList();
  }

  Future<Staff?> getStaffById(int id) async {
    await _ensureAuthorized();
    final map = await dbService.getStaffById(id);
    if (map == null) {
      return null;
    }
    return Staff.fromJson(map);
  }

  Future<Staff> createStaff({
    required String email,
    required String firstName,
    required String lastName,
    required String avatar,
  }) async {
    await _ensureAuthorized();
    final id = await dbService.createStaff({
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    });
    return Staff(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
    );
  }

  Future<bool> updateStaff(Staff staff) {
    return _authorizedUpdateStaff(staff);
  }

  Future<bool> deleteStaff(int id) {
    return _authorizedDeleteStaff(id);
  }

  Future<bool> _authorizedUpdateStaff(Staff staff) async {
    await _ensureAuthorized();
    return dbService.updateStaff(staff.toJson());
  }

  Future<bool> _authorizedDeleteStaff(int id) async {
    await _ensureAuthorized();
    return dbService.deleteStaff(id);
  }

  Future<void> _ensureAuthorized() async {
    final session = await dbService.getSession();
    final token = session?['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized access. Please log in first.');
    }

    final payload = JwtTokenService.verifyToken(token);
    if (payload == null) {
      await dbService.clearToken();
      throw Exception('Session expired. Please log in again.');
    }

    final sessionEmail = session?['email'] as String?;
    if (sessionEmail == null || payload['email'] != sessionEmail) {
      await dbService.clearToken();
      throw Exception('Invalid session. Please log in again.');
    }
  }
}
