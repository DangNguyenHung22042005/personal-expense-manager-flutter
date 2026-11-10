import '../models/admin_user.dart';

abstract interface class UserRepository {
  Future<List<AdminUser>> getUsers();

  Future<AdminUser?> getUserByEmail(String email);

  Future<AdminUser> createUser(AdminUser user);

  Future<AdminUser> updateUser({
    required String originalEmail,
    required AdminUser user,
  });

  Future<void> deleteUser(String email);
}
