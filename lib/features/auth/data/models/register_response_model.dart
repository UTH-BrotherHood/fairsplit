import 'package:fairsplit/features/auth/data/models/user_model.dart';

class RegisterDataModel {
  final UserModel user;
  final bool emailSent;
  final NextStepsModel nextSteps;

  RegisterDataModel({
    required this.user,
    required this.emailSent,
    required this.nextSteps,
  });

  factory RegisterDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterDataModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      emailSent: json['emailSent'] ?? false,
      nextSteps: NextStepsModel.fromJson(json['next_steps'] ?? {}),
    );
  }
}

class NextStepsModel {
  final String action;
  final String message;

  NextStepsModel({required this.action, required this.message});

  factory NextStepsModel.fromJson(Map<String, dynamic> json) {
    return NextStepsModel(
      action: json['action'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class RegisterResponseModel {
  final String message;
  final int status;
  final RegisterDataModel data;

  RegisterResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: RegisterDataModel.fromJson(json['data'] ?? {}),
    );
  }
}
