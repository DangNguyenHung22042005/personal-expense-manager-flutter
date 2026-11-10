class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
  });

  final String id;
  final String username;
  final String displayName;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppUser &&
            id == other.id &&
            username == other.username &&
            displayName == other.displayName;
  }

  @override
  int get hashCode => Object.hash(id, username, displayName);
}
