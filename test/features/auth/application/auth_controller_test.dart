import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_manager/core/constants/demo_account.dart';
import 'package:personal_expense_manager/features/auth/application/auth_controller.dart';
import 'package:personal_expense_manager/features/auth/data/repositories/in_memory_auth_repository.dart';

void main() {
  late AuthController controller;

  setUp(() {
    controller = AuthController(repository: InMemoryAuthRepository());
  });

  tearDown(() {
    controller.dispose();
  });

  group('AuthController', () {
    test('exposes loading and authenticates valid credentials', () async {
      final signInFuture = controller.signIn(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      expect(controller.isLoading, isTrue);
      expect(await signInFuture, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser?.displayName, 'Quản trị viên');
      expect(controller.errorMessage, isNull);
    });

    test('stores a friendly error for invalid credentials', () async {
      final succeeded = await controller.signIn(
        email: DemoAccount.email,
        password: 'wrong-password',
      );

      expect(succeeded, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage, 'Email hoặc mật khẩu không đúng.');

      controller.clearError();
      expect(controller.errorMessage, isNull);
    });

    test('signs out the current user', () async {
      await controller.signIn(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      await controller.signOut();

      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
    });
  });
}
