import 'package:fairsplit/features/expenses/domain/entities/bill.dart';

abstract class BillRepository {
  Future<BillsResponse> getBills(String groupId);
  Future<BillResponse> getBillDetail(String billId);
  Future<BillResponse> createBill(CreateBillRequest request);
  Future<PaymentsResponse> getBillPayments(String billId);
  Future<BillResponse> addPayment(String billId, CreatePaymentRequest request);
  Future<Payment> getPaymentDetail(String billId, String paymentId);
  Future<Payment> updatePayment(
    String billId,
    String paymentId,
    CreatePaymentRequest request,
  );
  Future<void> deletePayment(String billId, String paymentId);
}
