import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:scmp_staff_app/viewmodels/auth_viewmodel.dart';
import 'helpers/test_helpers.mocks.dart';

void main() {
  late AuthViewModel authViewModel;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authViewModel = AuthViewModel(authRepository: mockAuthRepository);
  });

  group('AuthViewModel Tests', () {
    test('Initial state is AuthState.initial', () {
      expect(authViewModel.state, AuthState.initial);
    });

    test('login success updates state to AuthState.success', () async {
      when(mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'))
          .thenAnswer((_) async => 'fake_token');

      await authViewModel.login('eve.holt@reqres.in', 'cityslicka');

      expect(authViewModel.state, AuthState.success);
      expect(authViewModel.token, 'fake_token');
      expect(authViewModel.errorMessage, isNull);
    });

    test('login failure updates state to AuthState.error', () async {
      when(mockAuthRepository.login('wrong@email.com', 'wrongpass'))
          .thenThrow(Exception('Invalid credentials'));

      await authViewModel.login('wrong@email.com', 'wrongpass');

      expect(authViewModel.state, AuthState.error);
      expect(authViewModel.errorMessage, 'Invalid credentials');
    });
  });
}
