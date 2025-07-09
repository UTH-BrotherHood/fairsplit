class ErrorDetailModel {
  final String msg;
  final String param;
  final String location;
  final String value;

  ErrorDetailModel({
    required this.msg,
    required this.param,
    required this.location,
    required this.value,
  });

  factory ErrorDetailModel.fromJson(Map<String, dynamic> json) {
    return ErrorDetailModel(
      msg: json['msg'] ?? '',
      param: json['param'] ?? '',
      location: json['location'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class ErrorModel {
  final String message;
  final int status;
  final String code;
  final Map<String, ErrorDetailModel> details;

  ErrorModel({
    required this.message,
    required this.status,
    required this.code,
    required this.details,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'] as Map<String, dynamic>? ?? {};
    final details = detailsJson.map(
      (key, value) => MapEntry(
        key,
        ErrorDetailModel.fromJson(value as Map<String, dynamic>),
      ),
    );

    return ErrorModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      code: json['code'] ?? '',
      details: details,
    );
  }

  String getFormattedErrorMessage() {
    if (details.isEmpty) {
      return message;
    }

    final errorMessages = details.values.map((detail) => detail.msg).toList();
    return errorMessages.join('\n');
  }
}

class ErrorResponseModel {
  final ErrorModel error;

  ErrorResponseModel({required this.error});

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(error: ErrorModel.fromJson(json['error'] ?? {}));
  }
}
