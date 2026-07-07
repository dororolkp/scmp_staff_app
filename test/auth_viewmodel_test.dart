import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:scmp_staff_app/viewmodels/auth_viewmodel.dart';
import 'dart:async';
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
      expect(authViewModel.token, isNull);
      expect(authViewModel.errorMessage, isNull);
    });

    test('login sets loading before resolving and ends in success', () async {
      final completer = Completer<String>();
      when(
        mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'),
      ).thenAnswer((_) => completer.future);

      final future = authViewModel.login('eve.holt@reqres.in', 'cityslicka');

      expect(authViewModel.state, AuthState.loading);
      expect(authViewModel.errorMessage, isNull);

      completer.complete('fake_token');
      await future;

      expect(authViewModel.state, AuthState.success);
      expect(authViewModel.token, 'fake_token');
      expect(authViewModel.errorMessage, isNull);
    });

    test('login success updates state to AuthState.success', () async {
      when(
        mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'),
      ).thenAnswer((_) async => 'fake_token');

      await authViewModel.login('eve.holt@reqres.in', 'cityslicka');

      expect(authViewModel.state, AuthState.success);
      expect(authViewModel.token, 'fake_token');
      expect(authViewModel.errorMessage, isNull);
    });

    test('login failure updates state to AuthState.error', () async {
      when(
        mockAuthRepository.login('wrong@email.com', 'wrongpass'),
      ).thenThrow(Exception('Invalid credentials'));

      await authViewModel.login('wrong@email.com', 'wrongpass');

      expect(authViewModel.state, AuthState.error);
      expect(authViewModel.errorMessage, 'Invalid credentials');
      expect(authViewModel.token, isNull);
    });

    test('successful login clears a previous error message', () async {
      when(mockAuthRepository.login('wrong@email.com', 'wrongpass'))
          .thenThrow(Exception('Invalid credentials'));
      await authViewModel.login('wrong@email.com', 'wrongpass');
      expect(authViewModel.errorMessage, 'Invalid credentials');

      reset(mockAuthRepository);
      when(mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'))
          .thenAnswer((_) async => 'fake_token');
      await authViewModel.login('eve.holt@reqres.in', 'cityslicka');

      expect(authViewModel.state, AuthState.success);
      expect(authViewModel.errorMessage, isNull);
      expect(authViewModel.token, 'fake_token');
    });

    test('checkToken restores saved token and marks state as success', () async {
      when(mockAuthRepository.getToken()).thenAnswer((_) async => 'saved_token');

      await authViewModel.checkToken();

      expect(authViewModel.state, AuthState.success);
      expect(authViewModel.token, 'saved_token');
      verify(mockAuthRepository.getToken()).called(1);
    });

    test('checkToken keeps initial state when there is no saved token', () async {
      when(mockAuthRepository.getToken()).thenAnswer((_) async => null);

      await authViewModel.checkToken();

      expect(authViewModel.state, AuthState.initial);
      expect(authViewModel.token, isNull);
      expect(authViewModel.errorMessage, isNull);
      verify(mockAuthRepository.getToken()).called(1);
    });

    test('login notifies listeners when state changes', () async {
      var notificationCount = 0;
      when(mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'))
          .thenAnswer((_) async => 'fake_token');
      authViewModel.addListener(() {
        notificationCount++;
      });

      await authViewModel.login('eve.holt@reqres.in', 'cityslicka');

      expect(notificationCount, 2);
    });
  });
}
