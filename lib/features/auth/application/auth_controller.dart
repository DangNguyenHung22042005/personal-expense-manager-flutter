import 'package:flutter/foundation.dart';

import '../domain/errors/auth_exception.dart';
import '../domain/models/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.repository});

  final AuthRepository repository;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await repository.signIn(
        username: username,
        password: password,
      );
      return true;
    } on InvalidCredentialsException {
      _errorMessage = 'Tên đăng nhập hoặc mật khẩu không đúng.';
      return false;
    } catch (error) {
      _errorMessage = 'Không thể đăng nhập: $error';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await repository.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
