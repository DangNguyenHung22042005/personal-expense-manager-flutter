import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/errors/auth_exception.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const InvalidCredentialsException();

      return AppUser(
        id: user.uid,
        email: user.email ?? email.trim(),
        displayName: user.displayName ?? 'Quản trị viên',
      );
    } on FirebaseAuthException catch (error) {
      if ({
        'invalid-credential',
        'invalid-email',
        'user-disabled',
        'user-not-found',
        'wrong-password',
      }.contains(error.code)) {
        throw const InvalidCredentialsException();
      }
      throw AuthServiceException(
        error.message ?? 'Không thể kết nối Firebase Authentication.',
      );
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
