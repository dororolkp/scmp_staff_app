import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:scmp_staff_app/di/injection.dart';
import 'package:scmp_staff_app/models/staff.dart';
import 'package:scmp_staff_app/repositories/staff_repository.dart';
import 'package:scmp_staff_app/viewmodels/auth_viewmodel.dart';
import 'package:scmp_staff_app/viewmodels/staff_viewmodel.dart';
import 'package:scmp_staff_app/views/login_view.dart';
import 'helpers/test_helpers.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockStaffRepository mockStaffRepository;

  Future<void> pumpLoginView(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));
  }

  setUp(() async {
    mockAuthRepository = MockAuthRepository();
    mockStaffRepository = MockStaffRepository();

    await getIt.reset();
    getIt.registerFactory<AuthViewModel>(
      () => AuthViewModel(authRepository: mockAuthRepository),
    );
    getIt.registerFactory<StaffViewModel>(
      () => StaffViewModel(staffRepository: mockStaffRepository),
    );

    when(mockStaffRepository.getToken()).thenAnswer((_) async => 'saved_token');
    when(mockStaffRepository.getStaffList(1)).thenAnswer(
      (_) async => StaffResponse(
        data: <Staff>[],
        totalPages: 1,
        page: 1,
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('LoginView widget', () {
    testWidgets('renders login form and action button', (
      WidgetTester tester,
    ) async {
      await pumpLoginView(tester);

      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('shows required validation messages for empty fields', (
      WidgetTester tester,
    ) async {
      await pumpLoginView(tester);
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      verifyNever(mockAuthRepository.login(any, any));
    });

    testWidgets('shows invalid email validation message', (
      WidgetTester tester,
    ) async {
      await pumpLoginView(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'wrong-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      verifyNever(mockAuthRepository.login(any, any));
    });

    testWidgets('shows password length validation message', (
      WidgetTester tester,
    ) async {
      await pumpLoginView(tester);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'eve.holt@reqres.in',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Password must be 6-10 characters'), findsOneWidget);
      verifyNever(mockAuthRepository.login(any, any));
    });

    testWidgets('shows alphanumeric password validation message', (
      WidgetTester tester,
    ) async {
      await pumpLoginView(tester);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'eve.holt@reqres.in',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'abc123!');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(
        find.text('Password must contain only letters and numbers'),
        findsOneWidget,
      );
      verifyNever(mockAuthRepository.login(any, any));
    });

    testWidgets('tapping valid credentials triggers login', (
      WidgetTester tester,
    ) async {
      when(
        mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'),
      ).thenAnswer((_) async => 'local-sqlite-session');

      await pumpLoginView(tester);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'eve.holt@reqres.in',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'cityslicka');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      verify(mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'))
          .called(1);
    });

    testWidgets('shows loading state while logging in', (
      WidgetTester tester,
    ) async {
      final completer = Completer<String>();
      when(
        mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'),
      ).thenAnswer((_) => completer.future);

      await pumpLoginView(tester);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'eve.holt@reqres.in',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'cityslicka');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Logging in...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'))
          .called(1);

      completer.complete('fake_token');
    });

    testWidgets('navigates to staff directory after successful login', (
      WidgetTester tester,
    ) async {
      when(
        mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'),
      ).thenAnswer((_) async => 'fake_token');

      await pumpLoginView(tester);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'eve.holt@reqres.in',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'cityslicka');
      await tester.tap(find.text('Log In'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Staff List'), findsOneWidget);
      expect(find.textContaining('Token:'), findsOneWidget);
    });

    testWidgets('shows error dialog when login fails', (
      WidgetTester tester,
    ) async {
      when(
        mockAuthRepository.login('eve.holt@reqres.in', 'cityslicka'),
      ).thenThrow(Exception('Invalid credentials'));

      await pumpLoginView(tester);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'eve.holt@reqres.in',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'cityslicka');
      await tester.tap(find.text('Log In'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
