class Bill {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String splitMethod; // 'equal' or 'percentage'
  final String paidBy;
  final List<BillParticipant> participants;
  final String status; // 'pending', 'partially_paid', 'paid'
  final List<Payment> payments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
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

  Bill copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    double? amount,
    String? currency,
    DateTime? date,
    String? category,
    String? splitMethod,
    String? paidBy,
    List<BillParticipant>? participants,
    String? status,
    List<Payment>? payments,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      category: category ?? this.category,
      splitMethod: splitMethod ?? this.splitMethod,
      paidBy: paidBy ?? this.paidBy,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      payments: payments ?? this.payments,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BillParticipant {
  final String userId;
  final double share;
  final double amountOwed;
  final String? username;
  final String? avatarUrl;

  BillParticipant({
    required this.userId,
    required this.share,
    required this.amountOwed,
    this.username,
    this.avatarUrl,
  });

  BillParticipant copyWith({
    String? userId,
    double? share,
    double? amountOwed,
    String? username,
    String? avatarUrl,
  }) {
    return BillParticipant(
      userId: userId ?? this.userId,
      share: share ?? this.share,
      amountOwed: amountOwed ?? this.amountOwed,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class Payment {
  final String id;
  final double amount;
  final String paidBy;
  final String paidTo;
  final DateTime date;
  final String method; // 'cash', 'bank_transfer', 'other'
  final String notes;
  final String createdBy;
  final DateTime createdAt;

  Payment({
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

  Payment copyWith({
    String? id,
    double? amount,
    String? paidBy,
    String? paidTo,
    DateTime? date,
    String? method,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      paidTo: paidTo ?? this.paidTo,
      date: date ?? this.date,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Request models
class CreateBillRequest {
  final String groupId;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String splitMethod;
  final String paidBy;
  final List<CreateBillParticipant> participants;
  final String status;
  final List<dynamic> payments;

  CreateBillRequest({
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
    this.status = 'pending',
    this.payments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
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
      'payments': payments,
    };
  }
}

class CreateBillParticipant {
  final String userId;

  CreateBillParticipant({required this.userId});

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }
}

class CreatePaymentRequest {
  final double amount;
  final String paidBy;
  final String paidTo;
  final DateTime date;
  final String method;
  final String notes;

  CreatePaymentRequest({
    required this.amount,
    required this.paidBy,
    required this.paidTo,
    required this.date,
    required this.method,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'paidBy': paidBy,
      'paidTo': paidTo,
      'date': date.toIso8601String(),
      'method': method,
      'notes': notes,
    };
  }
}

// Response models
class BillsResponse {
  final String message;
  final List<Bill> data;

  BillsResponse({required this.message, required this.data});
}

class BillResponse {
  final String message;
  final Bill result;

  BillResponse({required this.message, required this.result});
}

class PaymentsResponse {
  final String message;
  final List<Payment> result;

  PaymentsResponse({required this.message, required this.result});
}
