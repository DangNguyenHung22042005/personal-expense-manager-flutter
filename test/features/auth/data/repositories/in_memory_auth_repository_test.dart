import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/core/constants/demo_account.dart';
import 'package:personal_expense_manager/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:personal_expense_manager/features/auth/domain/errors/auth_exception.dart';

void main() {
  late InMemoryAuthRepository repository;

  setUp(() {
    repository = InMemoryAuthRepository();
  });

  group('InMemoryAuthRepository', () {
    test('signs in with the demo administrator account', () async {
      final user = await repository.signIn(
        username: DemoAccount.username,
        password: DemoAccount.password,
      );

      expect(user.id, 'demo-admin');
      expect(user.username, DemoAccount.username);
      expect(user.displayName, 'Quản trị viên');
    });

    test('accepts surrounding spaces and username case differences', () async {
      final user = await repository.signIn(
        username: '  ADMIN  ',
        password: DemoAccount.password,
      );

      expect(user.username, DemoAccount.username);
    });

    test('rejects invalid credentials', () async {
      await expectLater(
        repository.signIn(username: 'admin', password: 'wrong-password'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });
}
