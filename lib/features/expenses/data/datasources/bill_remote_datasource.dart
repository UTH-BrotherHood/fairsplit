import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/data/models/bill_model.dart';
import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class BillRemoteDataSource {
  Future<BillsResponseModel> getBills(String groupId);
  Future<BillResponseModel> getBillDetail(String billId);
  Future<BillResponseModel> createBill(CreateBillRequest request);
  Future<PaymentsResponseModel> getBillPayments(String billId);
  Future<BillResponseModel> addPayment(
    String billId,
    CreatePaymentRequest request,
  );
  Future<PaymentModel> getPaymentDetail(String billId, String paymentId);
  Future<PaymentModel> updatePayment(
    String billId,
    String paymentId,
    CreatePaymentRequest request,
  );
  Future<void> deletePayment(String billId, String paymentId);
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  final http.Client client;

  BillRemoteDataSourceImpl({required this.client});

  @override
  Future<BillsResponseModel> getBills(String groupId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/bills?groupId=$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return BillsResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get bills: ${response.statusCode}');
    }
  }

  @override
  Future<BillResponseModel> getBillDetail(String billId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/bills/$billId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return BillResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get bill detail: ${response.statusCode}');
    }
  }

  @override
  Future<BillResponseModel> createBill(CreateBillRequest request) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/bills'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BillResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create bill: ${response.statusCode}');
    }
  }

  @override
  Future<PaymentsResponseModel> getBillPayments(String billId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/bills/$billId/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return PaymentsResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get bill payments: ${response.statusCode}');
    }
  }

  @override
  Future<BillResponseModel> addPayment(
    String billId,
    CreatePaymentRequest request,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/bills/$billId/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BillResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add payment: ${response.statusCode}');
    }
  }

  @override
  Future<PaymentModel> getPaymentDetail(String billId, String paymentId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/bills/$billId/payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentModel.fromJson(data['result']);
    } else {
      throw Exception('Failed to get payment detail: ${response.statusCode}');
    }
  }

  @override
  Future<PaymentModel> updatePayment(
    String billId,
    String paymentId,
    CreatePaymentRequest request,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/bills/$billId/payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentModel.fromJson(data['result']);
    } else {
      throw Exception('Failed to update payment: ${response.statusCode}');
    }
  }

  @override
  Future<void> deletePayment(String billId, String paymentId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/bills/$billId/payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete payment: ${response.statusCode}');
    }
  }
}
