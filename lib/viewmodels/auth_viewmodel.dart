import 'package:flutter/material.dart';
import 'package:scmp_staff_app/repositories/auth_repository.dart';

enum AuthState { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthViewModel({required this.authRepository});

  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  String? get token => _token;

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final t = await authRepository.login(email, password);
      _token = t;
      _state = AuthState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _state = AuthState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> checkToken() async {
    final t = await authRepository.getToken();
    if (t != null) {
      _token = t;
      _state = AuthState.success;
      notifyListeners();
    }
  }
}
