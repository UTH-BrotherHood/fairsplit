import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/domain/repositories/bill_repository.dart';
import 'package:fairsplit/features/groups/domain/repositories/group_repository.dart';

class AllBillsState {
  final Map<String, List<Bill>> groupBills;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  AllBillsState({
    this.groupBills = const {},
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  AllBillsState copyWith({
    Map<String, List<Bill>>? groupBills,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return AllBillsState(
      groupBills: groupBills ?? this.groupBills,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class AllBillsNotifier extends StateNotifier<AllBillsState> {
  final BillRepository _billRepository;
  final GroupRepository _groupRepository;

  AllBillsNotifier(this._billRepository, this._groupRepository)
    : super(AllBillsState());

  Future<void> loadAllBills() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final groupsResponse = await _groupRepository.getMyGroups();
      if (!mounted) return;

      final groups = groupsResponse.items;
      Map<String, List<Bill>> allBills = {};

      for (final group in groups) {
        if (!mounted) return;

        List<Bill> bills = [];
        for (final groupBill in group.bills) {
          final bill = Bill(
            id: groupBill.id,
            groupId: groupBill.groupId,
            title: groupBill.title,
            description: groupBill.description,
            amount: groupBill.amount,
            currency: groupBill.currency,
            date: groupBill.date,
            category: groupBill.category,
            splitMethod: groupBill.splitMethod,
            paidBy: groupBill.paidBy,
            participants: groupBill.participants,
            status: groupBill.status,
            payments: groupBill.payments,
            createdBy: groupBill.createdBy,
            createdAt: groupBill.createdAt,
            updatedAt: groupBill.updatedAt,
          );
          bills.add(bill);
        }

        if (bills.isNotEmpty) {
          allBills[group.name] = bills;
        }
      }

      if (!mounted) return;
      state = state.copyWith(groupBills: allBills, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi tải danh sách hóa đơn: ${e.toString()}',
      );
    }
  }

  Future<void> createBill(CreateBillRequest request) async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _billRepository.createBill(request);
      if (!mounted) return;

      state = state.copyWith(
        successMessage: 'Tạo hóa đơn thành công',
        isLoading: false,
      );

      // Refresh bills after creating
      await loadAllBills();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi tạo hóa đơn: ${e.toString()}',
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

      // Refresh bills after deleting
      await loadAllBills();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi xóa hóa đơn: ${e.toString()}',
      );
    }
  }

  void clearMessages() {
    if (!mounted) return;
    state = state.copyWith(error: null, successMessage: null);
  }
}
