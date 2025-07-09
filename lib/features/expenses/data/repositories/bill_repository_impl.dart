import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/domain/repositories/bill_repository.dart';
import 'package:fairsplit/features/expenses/data/datasources/bill_remote_datasource.dart';

class BillRepositoryImpl implements BillRepository {
  final BillRemoteDataSource remoteDataSource;

  BillRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BillsResponse> getBills(String groupId) async {
    final response = await remoteDataSource.getBills(groupId);
    return response.toEntity();
  }

  @override
  Future<BillResponse> getBillDetail(String billId) async {
    final response = await remoteDataSource.getBillDetail(billId);
    return response.toEntity();
  }

  @override
  Future<BillResponse> createBill(CreateBillRequest request) async {
    final response = await remoteDataSource.createBill(request);
    return response.toEntity();
  }

  @override
  Future<PaymentsResponse> getBillPayments(String billId) async {
    final response = await remoteDataSource.getBillPayments(billId);
    return response.toEntity();
  }

  @override
  Future<BillResponse> addPayment(
    String billId,
    CreatePaymentRequest request,
  ) async {
    final response = await remoteDataSource.addPayment(billId, request);
    return response.toEntity();
  }

  @override
  Future<Payment> getPaymentDetail(String billId, String paymentId) async {
    final response = await remoteDataSource.getPaymentDetail(billId, paymentId);
    return response.toEntity();
  }

  @override
  Future<Payment> updatePayment(
    String billId,
    String paymentId,
    CreatePaymentRequest request,
  ) async {
    final response = await remoteDataSource.updatePayment(
      billId,
      paymentId,
      request,
    );
    return response.toEntity();
  }

  @override
  Future<void> deletePayment(String billId, String paymentId) async {
    await remoteDataSource.deletePayment(billId, paymentId);
  }
}
