// auth_remote_data_source.dart: nơi thực hiện các request HTTP.

import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/auth/data/models/auth_response_model.dart';
import 'package:fairsplit/features/auth/data/models/register_response_model.dart';
import 'package:fairsplit/features/auth/data/models/error_response_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSource(this.client);

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        '639401568459-kki393tuvvagi964s96fg13a7fhscmra.apps.googleusercontent.com', // Nếu cần chỉ định
  );

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(jsonDecode(response.body));
    } else {
      final responseBody = jsonDecode(response.body);

      // Check if it's a structured error response
      if (responseBody.containsKey('error')) {
        final errorResponse = ErrorResponseModel.fromJson(responseBody);
        throw Exception(errorResponse.error.getFormattedErrorMessage());
      }

      // Fallback for simple error messages
      throw Exception(responseBody['message'] ?? 'Login failed');
    }
  }

  Future<RegisterResponseModel> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required DateTime dateOfBirth,
    String verificationType = 'email',
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/register'),
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'confirmPassword': confirmPassword,
        'dateOfBirth': dateOfBirth.toIso8601String().split(
          'T',
        )[0], // Format: 1990-01-01
        'verificationType': verificationType,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResponseModel.fromJson(jsonDecode(response.body));
    } else {
      final responseBody = jsonDecode(response.body);

      // Check if it's a structured error response
      if (responseBody.containsKey('error')) {
        final errorResponse = ErrorResponseModel.fromJson(responseBody);
        throw Exception(errorResponse.error.getFormattedErrorMessage());
      }

      // Fallback for simple error messages
      throw Exception(responseBody['message'] ?? 'Signup failed');
    }
  }

  Future signOut() async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final refreshToken = await AuthLocalDataSource().getRefreshToken();
    await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );
  }

  Future<AuthResponseModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User hủy đăng nhập

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('No idToken');

      // Gửi idToken lên backend
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      print("authRes 116s => $response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponseModel.fromJson(data);

        print("authRes 122 => $authResponse");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', authResponse.data.accessToken);
        await prefs.setString('refreshToken', authResponse.data.refreshToken);

        return authResponse;
      } else {
        throw Exception('Backend error: ${response.body}');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Refresh token failed');
    }
  }
}
