class CreatePaymentRequest {
  final double amount;
  final String paidBy;
  final String paidTo;
  final DateTime date;
  final String method;
  final String? notes;

  CreatePaymentRequest({
    required this.amount,
    required this.paidBy,
    required this.paidTo,
    required this.date,
    required this.method,
    this.notes,
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
