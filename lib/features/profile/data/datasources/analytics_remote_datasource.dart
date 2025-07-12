import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/profile/data/models/analytics_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class AnalyticsRemoteDatasource {
  Future<AnalyticsOverviewModel> getOverview();
  Future<List<MonthlyAnalyticsModel>> getMonthly();
  Future<List<YearlyAnalyticsModel>> getYearly();
  Future<CompareAnalyticsModel> getCompare(int month, int year);
}

class AnalyticsRemoteDatasourceImpl implements AnalyticsRemoteDatasource {
  final http.Client client;

  AnalyticsRemoteDatasourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<AnalyticsOverviewModel> getOverview() async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users/analytics/overview'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final overviewResponse = AnalyticsOverviewResponse.fromJson(jsonMap);
      return overviewResponse.data;
    } else {
      throw Exception(
        'Failed to get overview analytics: ${response.statusCode}',
      );
    }
  }

  @override
  Future<List<MonthlyAnalyticsModel>> getMonthly() async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users/analytics/monthly'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final monthlyResponse = MonthlyAnalyticsResponse.fromJson(jsonMap);
      return monthlyResponse.data;
    } else {
      throw Exception(
        'Failed to get monthly analytics: ${response.statusCode}',
      );
    }
  }

  @override
  Future<List<YearlyAnalyticsModel>> getYearly() async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users/analytics/yearly'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final yearlyResponse = YearlyAnalyticsResponse.fromJson(jsonMap);
      return yearlyResponse.data;
    } else {
      throw Exception('Failed to get yearly analytics: ${response.statusCode}');
    }
  }

  @override
  Future<CompareAnalyticsModel> getCompare(int month, int year) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final response = await client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/users/analytics/compare?month=$month&year=$year',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final compareResponse = CompareAnalyticsResponse.fromJson(jsonMap);
      return compareResponse.data;
    } else {
      throw Exception(
        'Failed to get compare analytics: ${response.statusCode}',
      );
    }
  }
}
