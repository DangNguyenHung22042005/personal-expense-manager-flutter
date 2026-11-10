import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/features/users/domain/models/admin_user.dart';

void main() {
  test('maps exactly the four fields required by the exam', () {
    const user = AdminUser(
      email: 'test@example.com',
      matkhau: '123456',
      hoten: 'Nguyễn Văn Test',
      hinhanh: 'image-url',
    );
    expect(
      user.toMap().keys,
      unorderedEquals(['email', 'matkhau', 'hoten', 'hinhanh']),
    );
    expect(AdminUser.fromMap(user.toMap()), user);
  });
}
