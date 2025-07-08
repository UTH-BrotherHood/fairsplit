// 1. Chức năng:
// Chứa các class đại diện cho dữ liệu (data models) mà app sử dụng, thường là các object được parse từ JSON trả về từ API hoặc lưu trữ local.
// Models thường là các class đơn giản (POJO/POCO), chỉ chứa dữ liệu, không chứa logic nghiệp vụ.
// 2. Ví dụ:
// user_model.dart: đại diện cho thông tin user.
// auth_response_model.dart: đại diện cho response khi đăng nhập.

class UserModel {
  final String id;
  final String name;
  final String email;
  // ...
  UserModel({required this.id, required this.name, required this.email});
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
