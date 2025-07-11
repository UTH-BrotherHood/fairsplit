import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/domain/repositories/bill_repository.dart';

class BillDetailState {
  final Bill? bill;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  BillDetailState({
    this.bill,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  BillDetailState copyWith({
    Bill? bill,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return BillDetailState(
      bill: bill ?? this.bill,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class BillDetailNotifier extends StateNotifier<BillDetailState> {
  final BillRepository _billRepository;

  BillDetailNotifier(this._billRepository) : super(BillDetailState());

  Future<void> getBillDetail(String billId) async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final billResponse = await _billRepository.getBillDetail(billId);
      if (!mounted) return;

      state = state.copyWith(bill: billResponse.result, isLoading: false);
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi tải thông tin bill: ${e.toString()}',
      );
    }
  }

  Future<void> addPayment(String billId, CreatePaymentRequest request) async {
    if (!mounted) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final billResponse = await _billRepository.addPayment(billId, request);

      if (!mounted) return;

      // Update local state with the new bill data from response
      state = state.copyWith(
        bill: billResponse.result,
        successMessage: 'Thêm thanh toán thành công',
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi thêm thanh toán: ${e.toString()}',
      );
    }
  }

  Future<void> updatePayment(
    String billId,
    String paymentId,
    CreatePaymentRequest request,
  ) async {
    if (!mounted) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedPayment = await _billRepository.updatePayment(
        billId,
        paymentId,
        request,
      );

      if (!mounted) return;

      // Update local state with the updated payment
      if (state.bill != null) {
        final updatedPayments = state.bill!.payments.map((payment) {
          if (payment.id == paymentId) {
            return updatedPayment;
          }
          return payment;
        }).toList();

        final updatedBill = state.bill!.copyWith(payments: updatedPayments);

        state = state.copyWith(
          bill: updatedBill,
          successMessage: 'Cập nhật thanh toán thành công',
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          successMessage: 'Cập nhật thanh toán thành công',
          isLoading: false,
        );

        // Fallback: refresh bill detail if no local state
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await getBillDetail(billId);
        }
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi cập nhật thanh toán: ${e.toString()}',
      );
    }
  }

  Future<void> deletePayment(String billId, String paymentId) async {
    if (!mounted) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      await _billRepository.deletePayment(billId, paymentId);

      if (!mounted) return;

      // Update local state to remove the deleted payment
      if (state.bill != null) {
        final updatedPayments = state.bill!.payments
            .where((payment) => payment.id != paymentId)
            .toList();

        final updatedBill = state.bill!.copyWith(payments: updatedPayments);

        state = state.copyWith(
          bill: updatedBill,
          successMessage: 'Xóa thanh toán thành công',
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          successMessage: 'Xóa thanh toán thành công',
          isLoading: false,
        );

        // Fallback: refresh bill detail if no local state
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await getBillDetail(billId);
        }
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi xóa thanh toán: ${e.toString()}',
      );
    }
  }

  void clearMessages() {
    if (!mounted) return;

    try {
      state = state.copyWith(error: null, successMessage: null);
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }

  Future<void> updateBill(String billId, CreateBillRequest request) async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final billResponse = await _billRepository.updateBill(billId, request);
      if (!mounted) return;

      state = state.copyWith(
        bill: billResponse.result,
        successMessage: 'Cập nhật hóa đơn thành công',
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi cập nhật hóa đơn: ${e.toString()}',
      );
    }
  }

  Future<void> deleteBill(String billId) async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _billRepository.deleteBill(billId);
      if (!mounted) return;

      state = state.copyWith(
        successMessage: 'Xóa hóa đơn thành công',
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi xóa hóa đơn: ${e.toString()}',
      );
    }
  }
}
