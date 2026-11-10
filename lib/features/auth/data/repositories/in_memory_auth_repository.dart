import '../../../../core/constants/demo_account.dart';
import '../../domain/errors/auth_exception.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  static const _demoUser = AppUser(
    id: 'demo-admin',
    email: DemoAccount.email,
    displayName: 'Quản trị viên',
  );

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final isValidEmail = email.trim().toLowerCase() == DemoAccount.email;
    final isValidPassword = password == DemoAccount.password;
    if (!isValidEmail || !isValidPassword) {
      throw const InvalidCredentialsException();
    }

    return _demoUser;
  }

  @override
  Future<void> signOut() async {}
}
