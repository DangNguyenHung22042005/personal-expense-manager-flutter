import '../../domain/models/admin_user.dart';

abstract final class SampleUsers {
  static List<AdminUser> create() => const [
    AdminUser(
      email: 'an.nguyen@example.com',
      matkhau: 'an123456',
      hoten: 'Nguyễn Văn An',
      hinhanh: '',
    ),
    AdminUser(
      email: 'binh.tran@example.com',
      matkhau: 'binh123456',
      hoten: 'Trần Ngọc Bình',
      hinhanh: '',
    ),
    AdminUser(
      email: 'chi.le@example.com',
      matkhau: 'chi123456',
      hoten: 'Lê Minh Chi',
      hinhanh: '',
    ),
  ];
}
