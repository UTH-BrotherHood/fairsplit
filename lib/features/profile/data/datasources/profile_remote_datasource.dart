import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/profile/data/models/get_profile_responese.dart';
import 'package:fairsplit/features/profile/data/models/update_profile_request.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';

abstract class ProfileRemoteDatasource {
  Future<User> fetchProfile();
  Future<User> updateProfile(UpdateProfileRequest request);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final http.Client client;
  ProfileRemoteDatasourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<User> fetchProfile() async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile}'),
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

  @override
  Future<User> updateProfile(UpdateProfileRequest request) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    if (accessToken == null) throw Exception('No access token');
    if (request.hasAvatarFile) {
      return await _updateProfileWithFile(request, accessToken);
    } else {
      return await _updateProfileWithJson(request, accessToken);
    }
  }

  Future<User> _updateProfileWithJson(
    UpdateProfileRequest request,
    String accessToken,
  ) async {
    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final profileRes = GetProfileResponseModel.fromJson(jsonMap);
      final userModel = profileRes.data;
      return userModel.toEntity();
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody['message'] ?? 'Update profile failed';
      throw Exception(errorMessage);
    }
  }

  Future<User> _updateProfileWithFile(
    UpdateProfileRequest request,
    String accessToken,
  ) async {
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'];
    final file = request.avatarFile!;
    final ext = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      throw Exception('Chỉ chấp nhận ảnh jpg, jpeg, png, gif, webp, heic');
    }

    final multipartRequest = http.MultipartRequest(
      'PATCH',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile}'),
    );
    multipartRequest.headers['Authorization'] = 'Bearer $accessToken';

    // Add avatar file with đúng contentType
    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final typeSplit = mimeType.split('/');
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      file.path,
      contentType: MediaType(typeSplit[0], typeSplit[1]),
    );
    multipartRequest.files.add(multipartFile);

    // Add các trường khác nếu có
    if (request.username != null) {
      multipartRequest.fields['username'] = request.username!;
    }
    if (request.email != null) {
      multipartRequest.fields['email'] = request.email!;
    }
    if (request.phone != null) {
      multipartRequest.fields['phone'] = request.phone!;
    }
    if (request.dateOfBirth != null) {
      multipartRequest.fields['dateOfBirth'] = request.dateOfBirth!
          .toIso8601String();
    }
    if (request.preferences != null) {
      multipartRequest.fields['preferences'] = jsonEncode(request.preferences!);
    }
    if (request.privacySettings != null) {
      multipartRequest.fields['privacySettings'] = jsonEncode(
        request.privacySettings!.toJson(),
      );
    }

    final streamedResponse = await client.send(multipartRequest);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final profileRes = GetProfileResponseModel.fromJson(jsonMap);
      final userModel = profileRes.data;
      return userModel.toEntity();
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody['message'] ?? 'Update profile failed';
      throw Exception(errorMessage);
    }
  }
}
