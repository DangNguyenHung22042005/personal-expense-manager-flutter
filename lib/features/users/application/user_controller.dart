import 'package:flutter/foundation.dart';

import '../domain/errors/user_repository_exception.dart';
import '../domain/models/admin_user.dart';
import '../domain/repositories/user_repository.dart';

class UserController extends ChangeNotifier {
  UserController({required this.repository});

  final UserRepository repository;

  List<AdminUser> _users = const [];
  String _query = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<AdminUser> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  int get totalUsers => _users.length;

  List<AdminUser> get filteredUsers {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return users;
    return _users
        .where(
          (user) =>
              user.hoten.toLowerCase().contains(normalizedQuery) ||
              user.email.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  AdminUser? findByEmail(String email) {
    final key = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email.trim().toLowerCase() == key) return user;
    }
    return null;
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await repository.getUsers();
    } catch (error) {
      _errorMessage = 'Không thể tải danh sách người dùng: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(AdminUser user) => _save(
    action: () => repository.createUser(user),
    failurePrefix: 'Không thể thêm người dùng',
  );

  Future<bool> updateUser({
    required String originalEmail,
    required AdminUser user,
  }) => _save(
    action: () =>
        repository.updateUser(originalEmail: originalEmail, user: user),
    failurePrefix: 'Không thể cập nhật người dùng',
  );

  Future<bool> deleteUser(String email) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await repository.deleteUser(email);
      _users = await repository.getUsers();
      return true;
    } on UserRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Không thể xóa người dùng: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void search(String value) {
    _query = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _save({
    required Future<AdminUser> Function() action,
    required String failurePrefix,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _users = await repository.getUsers();
      return true;
    } on UserRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = '$failurePrefix: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
