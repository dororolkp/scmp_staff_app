import 'package:flutter/material.dart';
import 'package:scmp_staff_app/models/staff.dart';
import 'package:scmp_staff_app/repositories/staff_repository.dart';

class StaffViewModel extends ChangeNotifier {
  final StaffRepository staffRepository;

  StaffViewModel({required this.staffRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaginating = false;
  bool get isPaginating => _isPaginating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  String? get token => _token;

  List<Staff> _staffList = [];
  List<Staff> get staffList => _staffList;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> init() async {
    _token = await staffRepository.getToken();
    await fetchStaff();
  }

  Future<void> fetchStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await staffRepository.getStaffList(1);
      _staffList = response.data;
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isPaginating || !hasMore) return;

    _isPaginating = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await staffRepository.getStaffList(nextPage);
      _staffList.addAll(response.data);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isPaginating = false;
      notifyListeners();
    }
  }
}
