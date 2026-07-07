import 'package:scmp_staff_app/core/services/api_service.dart';
import 'package:scmp_staff_app/core/services/database_service.dart';
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

  StaffRepository({required this.apiService, required this.dbService});

  Future<StaffResponse> getStaffList(int page) async {
    try {
      final response = await apiService.get('/users?page=$page');
      
      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> jsonList = response.data['data'];
        final totalPages = response.data['total_pages'];
        final currentPage = response.data['page'];
        
        final staffList = jsonList.map((json) => Staff.fromJson(json)).toList();
        
        // Cache to database if it's the first page
        if (page == 1) {
          final db = await dbService.database;
          await db.delete('staff'); // clear old cache
          for (var staff in staffList) {
            await db.insert('staff', staff.toJson());
          }
        }

        return StaffResponse(
          data: staffList,
          totalPages: totalPages,
          page: currentPage,
        );
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      // If error occurs on page 1, try to load from cache
      if (page == 1) {
        final db = await dbService.database;
        final maps = await db.query('staff');
        if (maps.isNotEmpty) {
          final staffList = maps.map((map) => Staff.fromJson(map)).toList();
          return StaffResponse(
            data: staffList,
            totalPages: 1, // Assume 1 page for cached data
            page: 1,
          );
        }
      }
      rethrow;
    }
  }

  Future<String?> getToken() async {
    return await dbService.getToken();
  }
}
