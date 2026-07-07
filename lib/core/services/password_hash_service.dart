import 'dart:convert';

import 'package:crypto/crypto.dart';

class PasswordHashService {
  static const String _salt = 'scmp_staff_app_auth_salt';

  static String hashPassword(String password) {
    final bytes = utf8.encode('$_salt:$password');
    return sha256.convert(bytes).toString();
  }
}
