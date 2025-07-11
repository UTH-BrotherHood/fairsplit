import 'package:fairsplit/features/expenses/domain/entities/bill.dart';

class BillModel {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String splitMethod;
  final String paidBy;
  final List<BillParticipantModel> participants;
  final String status;
  final List<PaymentModel> payments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    required this.splitMethod,
    required this.paidBy,
    required this.participants,
    required this.status,
    required this.payments,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['_id'] ?? '',
      groupId: json['groupId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      date: _parseDate(json['date']),
      category: json['category'] ?? '',
      splitMethod: json['splitMethod'] ?? 'equal',
      paidBy: json['paidBy'] ?? '',
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((p) => BillParticipantModel.fromJson(p))
              .toList() ??
          [],
      status: json['status'] ?? 'pending',
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map((p) => PaymentModel.fromJson(p))
              .toList() ??
          [],
      createdBy: json['createdBy'] ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return DateTime.now();
    } catch (e) {
      print('Error parsing date: $dateValue - $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'category': category,
      'splitMethod': splitMethod,
      'paidBy': paidBy,
      'participants': participants.map((p) => p.toJson()).toList(),
      'status': status,
      'payments': payments.map((p) => p.toJson()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Bill toEntity() {
    return Bill(
      id: id,
      groupId: groupId,
      title: title,
      description: description,
      amount: amount,
      currency: currency,
      date: date,
      category: category,
      splitMethod: splitMethod,
      paidBy: paidBy,
      participants: participants.map((p) => p.toEntity()).toList(),
      status: status,
      payments: payments.map((p) => p.toEntity()).toList(),
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class BillParticipantModel {
  final String userId;
  final double share;
  final double amountOwed;
  final String? username;
  final String? avatarUrl;

  BillParticipantModel({
    required this.userId,
    required this.share,
    required this.amountOwed,
    this.username,
    this.avatarUrl,
  });

  factory BillParticipantModel.fromJson(Map<String, dynamic> json) {
    return BillParticipantModel(
      userId: json['userId'] ?? '',
      share: (json['share'] ?? 0).toDouble(),
      amountOwed: (json['amountOwed'] ?? 0).toDouble(),
      username: json['username'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'share': share,
      'amountOwed': amountOwed,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  BillParticipant toEntity() {
    return BillParticipant(
      userId: userId,
      share: share,
      amountOwed: amountOwed,
      username: username,
      avatarUrl: avatarUrl,
    );
  }
}

class PaymentModel {
  final String id;
  final double amount;
  final String paidBy;
  final String paidTo;
  final DateTime date;
  final String method;
  final String notes;
  final String createdBy;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.paidBy,
    required this.paidTo,
    required this.date,
    required this.method,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidBy: json['paidBy'] ?? '',
      paidTo: json['paidTo'] ?? '',
      date: _parseDate(json['date']),
      method: json['method'] ?? 'cash',
      notes: json['notes'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return DateTime.now();
    } catch (e) {
      print('Error parsing date: $dateValue - $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'paidBy': paidBy,
      'paidTo': paidTo,
      'date': date.toIso8601String(),
      'method': method,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Payment toEntity() {
    return Payment(
      id: id,
      amount: amount,
      paidBy: paidBy,
      paidTo: paidTo,
      date: date,
      method: method,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}

// Response models
class BillsResponseModel {
  final String message;
  final List<BillModel> data;

  BillsResponseModel({required this.message, required this.data});

  factory BillsResponseModel.fromJson(Map<String, dynamic> json) {
    return BillsResponseModel(
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((bill) => BillModel.fromJson(bill))
              .toList() ??
          [],
    );
  }

  BillsResponse toEntity() {
    return BillsResponse(
      message: message,
      data: data.map((b) => b.toEntity()).toList(),
    );
  }
}

class BillResponseModel {
  final String message;
  final BillModel result;

  BillResponseModel({required this.message, required this.result});

  factory BillResponseModel.fromJson(Map<String, dynamic> json) {
    return BillResponseModel(
      message: json['message'] ?? '',
      result: BillModel.fromJson(json['data'] ?? json['result']),
    );
  }

  BillResponse toEntity() {
    return BillResponse(message: message, result: result.toEntity());
  }
}

class PaymentsResponseModel {
  final String message;
  final List<PaymentModel> result;

  PaymentsResponseModel({required this.message, required this.result});

  factory PaymentsResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentsResponseModel(
      message: json['message'] ?? '',
      result:
          (json['data'] as List<dynamic>?) // Changed from 'result' to 'data'
              ?.map((payment) => PaymentModel.fromJson(payment))
              .toList() ??
          [],
    );
  }

  PaymentsResponse toEntity() {
    return PaymentsResponse(
      message: message,
      result: result.map((p) => p.toEntity()).toList(),
    );
  }
}
