import '../../../../core/constants/demo_account.dart';
import '../../domain/errors/auth_exception.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  static const _demoUser = AppUser(
    id: 'demo-admin',
    username: DemoAccount.username,
    displayName: 'Quản trị viên',
  );

  @override
  Future<AppUser> signIn({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final isValidUsername =
        username.trim().toLowerCase() == DemoAccount.username;
    final isValidPassword = password == DemoAccount.password;
    if (!isValidUsername || !isValidPassword) {
      throw const InvalidCredentialsException();
    }

    return _demoUser;
  }

  @override
  Future<void> signOut() async {}
}
