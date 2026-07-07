import 'package:scmp_staff_app/core/services/api_service.dart';
import 'package:scmp_staff_app/core/services/database_service.dart';

class AuthRepository {
  final ApiService apiService;
  final DatabaseService dbService;

  AuthRepository({required this.apiService, required this.dbService});

  Future<String> login(String email, String password) async {
    try {
      final response = await apiService.post(
        '/login?delay=5',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.data != null && response.data['token'] != null) {
        final token = response.data['token'];
        await dbService.saveToken(token);
        return token;
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async {
    return await dbService.getToken();
  }

  Future<void> logout() async {
    await dbService.clearToken();
  }
}
