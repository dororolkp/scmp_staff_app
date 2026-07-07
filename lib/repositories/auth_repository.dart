import 'package:scmp_staff_app/core/services/database_service.dart';
import 'package:scmp_staff_app/core/services/jwt_token_service.dart';
import 'package:scmp_staff_app/core/services/password_hash_service.dart';

class AuthRepository {
  final DatabaseService dbService;

  AuthRepository({required this.dbService});

  Future<String> login(String email, String password) async {
    final hashedPassword = PasswordHashService.hashPassword(password);
    final user = await dbService.getAuthUserByCredentials(
      email: email,
      password: hashedPassword,
    );
    if (user == null) {
      throw Exception('Invalid email or password');
    }

    final userId = user['id'] as int;
    final normalizedEmail = user['email'] as String;
    final token = JwtTokenService.issueToken(
      userId: userId,
      email: normalizedEmail,
    );
    await dbService.saveToken(
      userId: userId,
      email: normalizedEmail,
      token: token,
    );
    return token;
  }

  Future<String?> getToken() async {
    final token = await dbService.getToken();
    if (token == null) {
      return null;
    }
    final payload = JwtTokenService.verifyToken(token);
    if (payload == null) {
      await dbService.clearToken();
      return null;
    }
    return token;
  }

  Future<void> logout() async {
    await dbService.clearToken();
  }
}
