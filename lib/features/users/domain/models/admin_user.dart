class AdminUser {
  const AdminUser({
    required this.email,
    required this.matkhau,
    required this.hoten,
    required this.hinhanh,
  });

  final String email;
  final String matkhau;
  final String hoten;
  final String hinhanh;

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      email: map['email'] as String? ?? '',
      matkhau: map['matkhau'] as String? ?? '',
      hoten: map['hoten'] as String? ?? '',
      hinhanh: map['hinhanh'] as String? ?? '',
    );
  }

  Map<String, String> toMap() => {
    'email': email,
    'matkhau': matkhau,
    'hoten': hoten,
    'hinhanh': hinhanh,
  };

  AdminUser copyWith({
    String? email,
    String? matkhau,
    String? hoten,
    String? hinhanh,
  }) {
    return AdminUser(
      email: email ?? this.email,
      matkhau: matkhau ?? this.matkhau,
      hoten: hoten ?? this.hoten,
      hinhanh: hinhanh ?? this.hinhanh,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUser &&
          email == other.email &&
          matkhau == other.matkhau &&
          hoten == other.hoten &&
          hinhanh == other.hinhanh;

  @override
  int get hashCode => Object.hash(email, matkhau, hoten, hinhanh);
}
