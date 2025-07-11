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
    required this.status,
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
  final double? share;

  CreateBillParticipant({required this.userId, this.share});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'userId': userId};
    if (share != null) {
      data['share'] = share;
    }
    return data;
  }
}

class UpdateBillRequest {
  final String? title;
  final String? description;
  final double? amount;
  final String? currency;
  final DateTime? date;
  final String? category;
  final String? splitMethod;
  final String? paidBy;
  final List<CreateBillParticipant>? participants;
  final String? status;

  UpdateBillRequest({
    this.title,
    this.description,
    this.amount,
    this.currency,
    this.date,
    this.category,
    this.splitMethod,
    this.paidBy,
    this.participants,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (amount != null) data['amount'] = amount;
    if (currency != null) data['currency'] = currency;
    if (date != null) data['date'] = date!.toIso8601String();
    if (category != null) data['category'] = category;
    if (splitMethod != null) data['splitMethod'] = splitMethod;
    if (paidBy != null) data['paidBy'] = paidBy;
    if (participants != null) {
      data['participants'] = participants!.map((p) => p.toJson()).toList();
    }
    if (status != null) data['status'] = status;
    return data;
  }
}
