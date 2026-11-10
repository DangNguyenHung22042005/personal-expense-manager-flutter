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
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      expect(user.id, 'demo-admin');
      expect(user.email, DemoAccount.email);
      expect(user.displayName, 'Quản trị viên');
    });

    test('accepts surrounding spaces and email case differences', () async {
      final user = await repository.signIn(
        email: '  ADMIN@GMAIL.COM  ',
        password: DemoAccount.password,
      );

      expect(user.email, DemoAccount.email);
    });

    test('rejects invalid credentials', () async {
      await expectLater(
        repository.signIn(email: 'admin@gmail.com', password: 'wrong-password'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });
}
