import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/groups/data/models/group_model.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class GroupRemoteDataSource {
  Future<GroupsResponse> getMyGroups({int page = 1, int limit = 10});
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final http.Client client;

  GroupRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<GroupsResponse> getMyGroups({int page = 1, int limit = 10}) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/groups/my-groups?page=$page&limit=$limit',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final groupsResponseModel = GroupsResponseModel.fromJson(jsonMap);
      return groupsResponseModel.toEntity();
    } else {
      throw Exception('Failed to fetch groups: ${response.statusCode}');
    }
  }
}
