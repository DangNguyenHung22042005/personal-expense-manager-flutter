import '../models/app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser> signIn({required String username, required String password});

  Future<void> signOut();
}
