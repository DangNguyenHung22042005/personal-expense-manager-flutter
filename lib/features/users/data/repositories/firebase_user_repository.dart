import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../domain/errors/user_repository_exception.dart';
import '../../domain/models/admin_user.dart';
import '../../domain/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({DatabaseReference? usersReference})
    : _usersReference =
          usersReference ?? FirebaseDatabase.instance.ref('users');

  final DatabaseReference _usersReference;

  @override
  Future<List<AdminUser>> getUsers() async {
    try {
      final snapshot = await _usersReference.get();
      final value = snapshot.value;
      if (value == null) return const [];
      if (value is! Map<Object?, Object?>) {
        throw const UserRepositoryException(
          'Dữ liệu Firebase không đúng cấu trúc.',
        );
      }

      final users = <AdminUser>[];
      for (final rawUser in value.values) {
        if (rawUser is Map<Object?, Object?>) {
          users.add(AdminUser.fromMap(_stringKeyedMap(rawUser)));
        }
      }
      users.sort(
        (a, b) => a.hoten.toLowerCase().compareTo(b.hoten.toLowerCase()),
      );
      return List.unmodifiable(users);
    } on FirebaseException catch (error) {
      throw UserRepositoryException(_firebaseMessage(error));
    }
  }

  @override
  Future<AdminUser?> getUserByEmail(String email) async {
    try {
      final snapshot = await _usersReference.child(_emailKey(email)).get();
      final value = snapshot.value;
      if (value == null) return null;
      if (value is! Map<Object?, Object?>) {
        throw const UserRepositoryException(
          'Dữ liệu người dùng không đúng cấu trúc.',
        );
      }
      return AdminUser.fromMap(_stringKeyedMap(value));
    } on FirebaseException catch (error) {
      throw UserRepositoryException(_firebaseMessage(error));
    }
  }

  @override
  Future<AdminUser> createUser(AdminUser user) async {
    try {
      final reference = _usersReference.child(_emailKey(user.email));
      if ((await reference.get()).exists) {
        throw const UserAlreadyExistsException();
      }
      await reference.set(user.toMap());
      return user;
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw UserRepositoryException(_firebaseMessage(error));
    }
  }

  @override
  Future<AdminUser> updateUser({
    required String originalEmail,
    required AdminUser user,
  }) async {
    try {
      final originalKey = _emailKey(originalEmail);
      final newKey = _emailKey(user.email);
      final originalReference = _usersReference.child(originalKey);
      if (!(await originalReference.get()).exists) {
        throw const UserNotFoundException();
      }
      if (newKey != originalKey &&
          (await _usersReference.child(newKey).get()).exists) {
        throw const UserAlreadyExistsException();
      }

      if (newKey == originalKey) {
        await originalReference.set(user.toMap());
      } else {
        await _usersReference.update({originalKey: null, newKey: user.toMap()});
      }
      return user;
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw UserRepositoryException(_firebaseMessage(error));
    }
  }

  @override
  Future<void> deleteUser(String email) async {
    try {
      final reference = _usersReference.child(_emailKey(email));
      if (!(await reference.get()).exists) {
        throw const UserNotFoundException();
      }
      await reference.remove();
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw UserRepositoryException(_firebaseMessage(error));
    }
  }

  String _emailKey(String email) {
    final bytes = utf8.encode(email.trim().toLowerCase());
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Map<String, dynamic> _stringKeyedMap(Map<Object?, Object?> value) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  String _firebaseMessage(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Firebase từ chối quyền truy cập. Hãy kiểm tra đăng nhập và Database Rules.';
    }
    return error.message ?? 'Không thể kết nối Firebase Realtime Database.';
  }
}
