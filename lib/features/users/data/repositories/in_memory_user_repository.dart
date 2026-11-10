import '../../domain/errors/user_repository_exception.dart';
import '../../domain/models/admin_user.dart';
import '../../domain/repositories/user_repository.dart';

class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository({Iterable<AdminUser> initialUsers = const []}) {
    for (final user in initialUsers) {
      _users[_key(user.email)] = user;
    }
  }

  final Map<String, AdminUser> _users = {};

  @override
  Future<List<AdminUser>> getUsers() async {
    final users = _users.values.toList()
      ..sort((a, b) => a.hoten.toLowerCase().compareTo(b.hoten.toLowerCase()));
    return List.unmodifiable(users);
  }

  @override
  Future<AdminUser?> getUserByEmail(String email) async => _users[_key(email)];

  @override
  Future<AdminUser> createUser(AdminUser user) async {
    final key = _key(user.email);
    if (_users.containsKey(key)) throw const UserAlreadyExistsException();
    _users[key] = user;
    return user;
  }

  @override
  Future<AdminUser> updateUser({
    required String originalEmail,
    required AdminUser user,
  }) async {
    final originalKey = _key(originalEmail);
    if (!_users.containsKey(originalKey)) throw const UserNotFoundException();

    final newKey = _key(user.email);
    if (newKey != originalKey && _users.containsKey(newKey)) {
      throw const UserAlreadyExistsException();
    }

    _users.remove(originalKey);
    _users[newKey] = user;
    return user;
  }

  @override
  Future<void> deleteUser(String email) async {
    if (_users.remove(_key(email)) == null) {
      throw const UserNotFoundException();
    }
  }

  String _key(String email) => email.trim().toLowerCase();
}
