class UserRepositoryException implements Exception {
  const UserRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserAlreadyExistsException extends UserRepositoryException {
  const UserAlreadyExistsException()
    : super('Email này đã được sử dụng bởi người dùng khác.');
}

class UserNotFoundException extends UserRepositoryException {
  const UserNotFoundException() : super('Không tìm thấy người dùng.');
}
