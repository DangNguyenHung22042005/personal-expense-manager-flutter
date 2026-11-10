# Thiết lập Firebase cho UserAdmin

## 1. Tạo Firebase project

1. Mở Firebase Console và chọn **Create a new Firebase project**.
2. Đặt tên, ví dụ `user-admin-midterm`.
3. Google Analytics không bắt buộc cho đồ án CRUD này.

## 2. Tạo Realtime Database

1. Trong project, mở **Build > Realtime Database**.
2. Chọn **Create Database**, chọn region gần Việt Nam.
3. Có thể chọn **Locked mode** vì rules của project sẽ được cấu hình ở bước sau.
4. Trong tab **Data**, chọn menu ba chấm > **Import JSON** và chọn `database.seed.json` nếu muốn có dữ liệu mẫu.

Không tạo thêm trường. Mỗi record trong `/users` chỉ được phép có:

- `email`
- `matkhau`
- `hoten`
- `hinhanh`

Key bên ngoài record là email đã mã hóa để Firebase chấp nhận dấu chấm trong email; key không phải một trường dữ liệu.

## 3. Cấu hình Database Rules

1. Mở **Realtime Database > Rules**.
2. Sao chép toàn bộ nội dung `database.rules.json` vào trình soạn thảo.
3. Chọn **Publish**.

Rules yêu cầu đăng nhập Firebase và từ chối mọi trường ngoài bốn trường của đề.

## 4. Bật đăng nhập admin

1. Mở **Build > Authentication > Get started**.
2. Trong **Sign-in method**, bật **Email/Password**.
3. Mở tab **Users > Add user**.
4. Tạo tài khoản:
   - Email: `admin@gmail.com`
   - Password: `admin123`

Tài khoản Authentication này dùng để bảo vệ phân hệ admin. Nó độc lập với các record CRUD trong `/users`.

## 5. Cài CLI và liên kết Flutter

Chạy trong terminal:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

Sau đó chuyển tới thư mục project và chạy:

```powershell
flutterfire configure
```

Trong trình cấu hình:

1. Chọn Firebase project vừa tạo.
2. Chọn `android` và `web` bằng phím Space.
3. Android package là `com.example.personal_expense_manager`.
4. Cho phép công cụ ghi đè `lib/firebase_options.dart` placeholder.

Sau khi cấu hình:

```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

## 6. File cơ sở dữ liệu để nộp

Sau khi demo và có đủ dữ liệu:

1. Mở **Realtime Database > Data**.
2. Chọn menu ba chấm ở node gốc.
3. Chọn **Export JSON**.
4. Nộp file JSON tải về cùng báo cáo/source theo yêu cầu giảng viên.

> Lưu ý học thuật: đề yêu cầu trường `matkhau` nên project lưu đúng trường này. Trong sản phẩm thực tế không nên lưu mật khẩu dạng văn bản; việc xác thực nên để Firebase Authentication quản lý.
