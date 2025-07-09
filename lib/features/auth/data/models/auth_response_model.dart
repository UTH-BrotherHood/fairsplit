// 1. Chức năng:
// Chứa các class đại diện cho dữ liệu (data models) mà app sử dụng, thường là các object được parse từ JSON trả về từ API hoặc lưu trữ local.
// Models thường là các class đơn giản (POJO/POCO), chỉ chứa dữ liệu, không chứa logic nghiệp vụ.
// 2. Ví dụ:
// user_model.dart: đại diện cho thông tin user.
// auth_response_model.dart: đại diện cho response khi đăng nhập.
import 'package:fairsplit/features/auth/data/models/user_model.dart';

class AuthDataModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthDataModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthDataModel.fromJson(Map<String, dynamic> json) {
    return AuthDataModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class AuthResponseModel {
  final String message;
  final int status;
  final AuthDataModel data;

  AuthResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: AuthDataModel.fromJson(json['data'] ?? {}),
    );
  }
}
