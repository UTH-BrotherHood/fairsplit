import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/profile/data/models/get_profile_responese.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ProfileRemoteDatasource {
  Future<User> fetchProfile();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final http.Client client;
  ProfileRemoteDatasourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<User> fetchProfile() async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final profileRes = GetProfileResponseModel.fromJson(jsonMap);
      final userModel = profileRes.data;
      return userModel.toEntity();
    } else {
      throw Exception('Fetch profile failed');
    }
  }
}
