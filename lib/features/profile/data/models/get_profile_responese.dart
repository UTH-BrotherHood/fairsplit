import 'package:fairsplit/features/auth/data/models/user_model.dart';

class GetProfileResponseModel {
  final String message;
  final int status;
  final UserModel data;

  GetProfileResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory GetProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return GetProfileResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: UserModel.fromJson(json['data'] ?? {}),
    );
  }
}
