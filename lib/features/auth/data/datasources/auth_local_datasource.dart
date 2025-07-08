// 1. Chức năng:
// Đây là nơi xử lý lưu trữ dữ liệu xác thực (auth) ở local device, ví dụ: token, thông tin user, refresh token, v.v.
// Thường sử dụng các package như shared_preferences, hive, hoặc secure_storage để lưu trữ.
// Không gọi API ở đây, chỉ thao tác với bộ nhớ cục bộ.
// 2. Ví dụ chức năng:
// Lưu access token sau khi đăng nhập thành công.
// Đọc access token để gửi kèm các request.
// Xóa token khi logout.
class AuthLocalDataSource {
  Future<void> saveToken(String token) async {
    /* ... */
  }
  Future<String?> getToken() async {
    /* ... */
    return 'qwe';
  }

  Future<void> clearToken() async {
    /* ... */
  }
}
