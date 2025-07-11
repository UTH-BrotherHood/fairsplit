import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/domain/repositories/bill_repository.dart';

// Provider for bills list
class BillsViewModel extends StateNotifier<AsyncValue<List<Bill>>> {
  final BillRepository repository;
  String? _currentGroupId;

  BillsViewModel({required this.repository}) : super(const AsyncLoading());

  Future<void> getBills(String groupId) async {
    _currentGroupId = groupId;
    state = const AsyncLoading();
    try {
      print('BillsViewModel: Getting bills for group: $groupId');
      final response = await repository.getBills(groupId);
      print('BillsViewModel: Got ${response.data.length} bills');
      state = AsyncData(response.data);
    } catch (e, st) {
      print('BillsViewModel: Error getting bills: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshBills() async {
    if (_currentGroupId != null) {
      await getBills(_currentGroupId!);
    }
  }

  Future<void> createBill(CreateBillRequest request) async {
    try {
      print('BillsViewModel: Creating bill with request: ${request.toJson()}');
      await repository.createBill(request);
      print('BillsViewModel: Bill created successfully');
      // Set the current group ID from the request and refresh
      _currentGroupId = request.groupId;
      print('BillsViewModel: Refreshing bills for group: $_currentGroupId');
      await getBills(_currentGroupId!);
    } catch (e, st) {
      print('BillsViewModel: Error creating bill: $e');
      print('Stack trace: $st');
      state = AsyncError(e, st);
    }
  }
}

// Provider for a specific bill detail
class BillDetailViewModel extends StateNotifier<AsyncValue<Bill>> {
  final BillRepository repository;
  String? _currentBillId;

  BillDetailViewModel({required this.repository}) : super(const AsyncLoading());

  Future<void> getBillDetail(String billId) async {
    _currentBillId = billId;
    state = const AsyncLoading();
    try {
      final response = await repository.getBillDetail(billId);
      state = AsyncData(response.result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshBill() async {
    if (_currentBillId != null) {
      await getBillDetail(_currentBillId!);
    }
  }

  Future<void> addPayment(CreatePaymentRequest request) async {
    if (_currentBillId == null) return;

    try {
      await repository.addPayment(_currentBillId!, request);
      // Refresh the bill to get updated data
      await getBillDetail(_currentBillId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateBill(String billId, CreateBillRequest request) async {
    try {
      await repository.updateBill(billId, request);
      // Refresh the bill to get updated data
      await getBillDetail(billId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await repository.deleteBill(billId);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Provider for bill payments
class BillPaymentsViewModel extends StateNotifier<AsyncValue<List<Payment>>> {
  final BillRepository repository;
  String? _currentBillId;

  BillPaymentsViewModel({required this.repository})
    : super(const AsyncLoading());

  Future<void> getBillPayments(String billId) async {
    _currentBillId = billId;
    state = const AsyncLoading();
    try {
      final response = await repository.getBillPayments(billId);
      state = AsyncData(response.result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshPayments() async {
    if (_currentBillId != null) {
      await getBillPayments(_currentBillId!);
    }
  }

  Future<void> deletePayment(String paymentId) async {
    if (_currentBillId == null) return;

    try {
      await repository.deletePayment(_currentBillId!, paymentId);
      // Refresh the payments list
      await getBillPayments(_currentBillId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePayment(
    String paymentId,
    CreatePaymentRequest request,
  ) async {
    if (_currentBillId == null) return;

    try {
      await repository.updatePayment(_currentBillId!, paymentId, request);
      // Refresh the payments list
      await getBillPayments(_currentBillId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
