import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:scmp_staff_app/models/staff.dart';
import 'package:scmp_staff_app/repositories/staff_repository.dart';
import 'package:scmp_staff_app/viewmodels/staff_viewmodel.dart';
import 'dart:async';
import 'helpers/test_helpers.mocks.dart';

void main() {
  late StaffViewModel staffViewModel;
  late MockStaffRepository mockStaffRepository;

  setUp(() {
    mockStaffRepository = MockStaffRepository();
    staffViewModel = StaffViewModel(staffRepository: mockStaffRepository);
  });

  group('StaffViewModel Tests', () {
    final mockStaffList = [
      Staff(
        id: 1,
        email: 'test1@test.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: '',
      ),
    ];

    test('initial state is empty and not loading', () {
      expect(staffViewModel.staffList, isEmpty);
      expect(staffViewModel.token, isNull);
      expect(staffViewModel.isLoading, isFalse);
      expect(staffViewModel.isPaginating, isFalse);
      expect(staffViewModel.hasMore, isFalse);
      expect(staffViewModel.errorMessage, isNull);
    });

    test('fetchStaff success updates staffList', () async {
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 2,
          page: 1,
        ),
      );

      await staffViewModel.fetchStaff();

      expect(staffViewModel.isLoading, false);
      expect(staffViewModel.staffList.length, 1);
      expect(staffViewModel.hasMore, true);
    });

    test('loadMore appends to staffList', () async {
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 2,
          page: 1,
        ),
      );
      when(mockStaffRepository.getStaffList(2)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 2,
          page: 2,
        ),
      );

      await staffViewModel.fetchStaff();
      await staffViewModel.loadMore();

      expect(staffViewModel.staffList.length, 2);
      expect(staffViewModel.hasMore, false);
    });

    test('init restores token and fetches first page', () async {
      when(mockStaffRepository.getToken()).thenAnswer((_) async => 'saved_token');
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 1,
          page: 1,
        ),
      );

      await staffViewModel.init();

      expect(staffViewModel.token, 'saved_token');
      expect(staffViewModel.staffList.length, 1);
      verify(mockStaffRepository.getToken()).called(1);
      verify(mockStaffRepository.getStaffList(1)).called(1);
    });

    test('fetchStaff failure stores error and stops loading', () async {
      when(
        mockStaffRepository.getStaffList(1),
      ).thenThrow(Exception('Network failed'));

      await staffViewModel.fetchStaff();

      expect(staffViewModel.isLoading, isFalse);
      expect(staffViewModel.staffList, isEmpty);
      expect(staffViewModel.errorMessage, 'Network failed');
    });

    test('fetchStaff clears a previous error after a successful retry', () async {
      when(mockStaffRepository.getStaffList(1))
          .thenThrow(Exception('Network failed'));

      await staffViewModel.fetchStaff();
      expect(staffViewModel.errorMessage, 'Network failed');

      reset(mockStaffRepository);
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 1,
          page: 1,
        ),
      );

      await staffViewModel.fetchStaff();

      expect(staffViewModel.errorMessage, isNull);
      expect(staffViewModel.staffList.length, 1);
    });

    test('loadMore does nothing when there are no more pages', () async {
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 1,
          page: 1,
        ),
      );

      await staffViewModel.fetchStaff();
      await staffViewModel.loadMore();

      verifyNever(mockStaffRepository.getStaffList(2));
      expect(staffViewModel.staffList.length, 1);
    });

    test('loadMore reports error and resets pagination flag on failure', () async {
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 2,
          page: 1,
        ),
      );
      when(
        mockStaffRepository.getStaffList(2),
      ).thenThrow(Exception('Page 2 failed'));

      await staffViewModel.fetchStaff();
      await staffViewModel.loadMore();

      expect(staffViewModel.isPaginating, isFalse);
      expect(staffViewModel.errorMessage, 'Page 2 failed');
      expect(staffViewModel.staffList.length, 1);
    });

    test('second loadMore call is ignored while pagination is in progress', () async {
      final completer = Completer<StaffResponse>();
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 2,
          page: 1,
        ),
      );
      when(mockStaffRepository.getStaffList(2)).thenAnswer((_) => completer.future);

      await staffViewModel.fetchStaff();
      final firstCall = staffViewModel.loadMore();
      await staffViewModel.loadMore();

      verify(mockStaffRepository.getStaffList(2)).called(1);
      expect(staffViewModel.isPaginating, isTrue);

      completer.complete(
        StaffResponse(
          data: List.from(mockStaffList),
          totalPages: 2,
          page: 2,
        ),
      );
      await firstCall;

      expect(staffViewModel.isPaginating, isFalse);
      expect(staffViewModel.staffList.length, 2);
    });
  });
}
