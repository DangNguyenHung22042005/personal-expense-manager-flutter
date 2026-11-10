# UserAdmin

Ứng dụng Flutter quản trị người dùng, chạy trên web và thiết bị di động.

## Tài khoản demo

- Email: `admin@gmail.com`
- Mật khẩu: `admin123`

## Chức năng hiện tại

- Đăng nhập/đăng xuất phân hệ admin.
- Thêm, hiển thị, sửa, xóa và tìm kiếm người dùng.
- Chọn và xem trước ảnh đại diện trên web/mobile.
- Dữ liệu thật trên Firebase Realtime Database thông qua `UserRepository`.
- Model dữ liệu chỉ gồm `email`, `matkhau`, `hoten`, `hinhanh`.

Xem [FIREBASE_SETUP.md](FIREBASE_SETUP.md) để tạo project, bật Authentication, cấu hình Realtime Database và xuất file JSON nộp bài.
