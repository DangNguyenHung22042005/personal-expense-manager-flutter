class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppUser &&
            id == other.id &&
            email == other.email &&
            displayName == other.displayName;
  }

  @override
  int get hashCode => Object.hash(id, email, displayName);
}
