import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:scmp_staff_app/models/staff.dart';
import 'package:scmp_staff_app/repositories/staff_repository.dart';
import 'package:scmp_staff_app/viewmodels/staff_viewmodel.dart';
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
      Staff(id: 1, email: 'test1@test.com', firstName: 'John', lastName: 'Doe', avatar: ''),
    ];

    test('fetchStaff success updates staffList', () async {
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(data: List.from(mockStaffList), totalPages: 2, page: 1),
      );

      await staffViewModel.fetchStaff();

      expect(staffViewModel.isLoading, false);
      expect(staffViewModel.staffList.length, 1);
      expect(staffViewModel.hasMore, true);
    });

    test('loadMore appends to staffList', () async {
      when(mockStaffRepository.getStaffList(1)).thenAnswer(
        (_) async => StaffResponse(data: List.from(mockStaffList), totalPages: 2, page: 1),
      );
      when(mockStaffRepository.getStaffList(2)).thenAnswer(
        (_) async => StaffResponse(data: List.from(mockStaffList), totalPages: 2, page: 2),
      );

      await staffViewModel.fetchStaff();
      await staffViewModel.loadMore();

      expect(staffViewModel.staffList.length, 2);
      expect(staffViewModel.hasMore, false);
    });
  });
}
