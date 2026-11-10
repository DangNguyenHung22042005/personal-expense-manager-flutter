import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/features/users/application/user_controller.dart';
import 'package:personal_expense_manager/features/users/data/repositories/in_memory_user_repository.dart';
import 'package:personal_expense_manager/features/users/domain/models/admin_user.dart';

void main() {
  const an = AdminUser(
    email: 'an@example.com',
    matkhau: '123456',
    hoten: 'Nguyễn An',
    hinhanh: '',
  );
  const binh = AdminUser(
    email: 'binh@example.com',
    matkhau: '123456',
    hoten: 'Trần Bình',
    hinhanh: '',
  );
  test('loads data and filters by name or email', () async {
    final controller = UserController(
      repository: InMemoryUserRepository(initialUsers: [an, binh]),
    );
    await controller.loadUsers();
    expect(controller.totalUsers, 2);
    controller.search('bình');
    expect(controller.filteredUsers, [binh]);
    controller.search('an@example');
    expect(controller.filteredUsers, [an]);
    controller.dispose();
  });
  test('exposes complete CRUD operations', () async {
    final controller = UserController(repository: InMemoryUserRepository());
    await controller.loadUsers();
    expect(await controller.createUser(an), isTrue);
    expect(controller.findByEmail(an.email), an);
    final updated = an.copyWith(hoten: 'Nguyễn An Mới');
    expect(
      await controller.updateUser(originalEmail: an.email, user: updated),
      isTrue,
    );
    expect(controller.findByEmail(an.email)?.hoten, 'Nguyễn An Mới');
    expect(await controller.deleteUser(an.email), isTrue);
    expect(controller.users, isEmpty);
    controller.dispose();
  });
}
