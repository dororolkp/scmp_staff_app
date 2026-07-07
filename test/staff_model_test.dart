import 'package:flutter_test/flutter_test.dart';
import 'package:scmp_staff_app/models/staff.dart';

void main() {
  group('Staff model', () {
    test('fromJson maps API fields correctly', () {
      final staff = Staff.fromJson({
        'id': 7,
        'email': 'jane@example.com',
        'first_name': 'Jane',
        'last_name': 'Doe',
        'avatar': 'https://example.com/avatar.png',
      });

      expect(staff.id, 7);
      expect(staff.email, 'jane@example.com');
      expect(staff.firstName, 'Jane');
      expect(staff.lastName, 'Doe');
      expect(staff.avatar, 'https://example.com/avatar.png');
    });

    test('toJson maps model fields back to API shape', () {
      final staff = Staff(
        id: 7,
        email: 'jane@example.com',
        firstName: 'Jane',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.png',
      );

      expect(staff.toJson(), {
        'id': 7,
        'email': 'jane@example.com',
        'first_name': 'Jane',
        'last_name': 'Doe',
        'avatar': 'https://example.com/avatar.png',
      });
    });
  });
}
