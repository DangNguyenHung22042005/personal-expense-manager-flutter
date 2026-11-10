import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/features/users/data/repositories/in_memory_user_repository.dart';
import 'package:personal_expense_manager/features/users/domain/errors/user_repository_exception.dart';
import 'package:personal_expense_manager/features/users/domain/models/admin_user.dart';

void main() {
  const user = AdminUser(
    email: 'a@example.com',
    matkhau: '123456',
    hoten: 'Nguyễn An',
    hinhanh: '',
  );
  test('creates, reads, updates and deletes a user', () async {
    final repository = InMemoryUserRepository();
    await repository.createUser(user);
    expect(await repository.getUserByEmail(' A@EXAMPLE.COM '), user);
    final updated = user.copyWith(
      email: 'new@example.com',
      hoten: 'Nguyễn An Mới',
    );
    await repository.updateUser(originalEmail: user.email, user: updated);
    expect(await repository.getUserByEmail(user.email), isNull);
    expect(await repository.getUserByEmail(updated.email), updated);
    await repository.deleteUser(updated.email);
    expect(await repository.getUsers(), isEmpty);
  });
  test('rejects duplicate email ignoring case', () async {
    final repository = InMemoryUserRepository(initialUsers: [user]);
    await expectLater(
      repository.createUser(user.copyWith(email: 'A@EXAMPLE.COM')),
      throwsA(isA<UserAlreadyExistsException>()),
    );
  });
}
