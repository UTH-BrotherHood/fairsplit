// auth_remote_data_source.dart: nơi thực hiện các request HTTP.

import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSource(this.client);

  Future<UserModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed');
    }
  }

  Future<UserModel> signUp(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/signup'),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'dob': dob.toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Signup failed');
    }
  }

  Future signOut() async {}

  Future signInWithGoogle() async {}
}
