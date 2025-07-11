import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/groups/data/models/group_model.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class GroupRemoteDataSource {
  // Group management
  Future<GroupsResponse> getMyGroups({int page = 1, int limit = 10});
  Future<GroupResponseModel> getGroup(String groupId);
  Future<GroupResponseModel> createGroup(CreateGroupRequest request);
  Future<GroupResponseModel> updateGroup(
    String groupId,
    UpdateGroupRequest request,
  );
  Future<void> deleteGroup(String groupId);

  // Member management
  Future<GroupMembersResponse> getGroupMembers(String groupId);
  Future<void> addMembers(String groupId, AddMembersRequest request);
  Future<void> updateMember(
    String groupId,
    String memberId,
    UpdateMemberRequest request,
  );
  Future<void> deleteMember(String groupId, String memberId);

  // User search
  Future<UserSearchResponse> searchUsers(String query);
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

  @override
  Future<GroupResponseModel> getGroup(String groupId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return GroupResponseModel.fromJson(jsonMap);
    } else {
      throw Exception('Failed to fetch group: ${response.statusCode}');
    }
  }

  @override
  Future<GroupResponseModel> createGroup(CreateGroupRequest request) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();
    final requestModel = CreateGroupRequestModel.fromEntity(request);

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/groups'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(requestModel.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      return GroupResponseModel.fromJson(jsonMap);
    } else {
      final errorBody = response.body;
      throw Exception(
        'Failed to create group: ${response.statusCode}, body: $errorBody',
      );
    }
  }

  @override
  Future<GroupResponseModel> updateGroup(
    String groupId,
    UpdateGroupRequest request,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return GroupResponseModel.fromJson(jsonMap);
    } else {
      throw Exception('Failed to update group: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete group: ${response.statusCode}');
    }
  }

  @override
  Future<GroupMembersResponse> getGroupMembers(String groupId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId/members'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return GroupMembersResponse(
        message: jsonMap['message'],
        result: (jsonMap['result'] as List)
            .map(
              (member) => GroupMember(
                userId: member['userId'],
                role: member['role'],
                joinedAt: DateTime.parse(member['joinedAt']),
                nickname: member['nickname'],
                user: GroupUser(
                  id: member['user']['_id'],
                  username: member['user']['username'],
                  email: member['user']['email'],
                  phone: member['user']['phone'],
                  avatarUrl: member['user']['avatarUrl'],
                  verify: member['user']['verify'],
                  blockedUsers: [],
                  lastLoginTime: member['user']['lastLoginTime'] != null
                      ? DateTime.parse(member['user']['lastLoginTime'])
                      : null,
                ),
              ),
            )
            .toList(),
      );
    } else {
      throw Exception('Failed to get group members: ${response.statusCode}');
    }
  }

  @override
  Future<void> addMembers(String groupId, AddMembersRequest request) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId/members'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add members: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateMember(
    String groupId,
    String memberId,
    UpdateMemberRequest request,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId/members/$memberId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update member: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteMember(String groupId, String memberId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId/members/$memberId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete member: ${response.statusCode}');
    }
  }

  @override
  Future<UserSearchResponse> searchUsers(String query) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/users/search?q=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final data = jsonMap['data'] ?? {};
      return UserSearchResponse(
        message: jsonMap['message'] ?? '',
        users:
            (data['users'] as List<dynamic>?)
                ?.map(
                  (user) => UserSearchResult(
                    id: user['_id'] ?? '',
                    username: user['username'] ?? '',
                    email: user['email'] ?? '',
                    phone: user['phone'] ?? '',
                    avatarUrl: user['avatarUrl'],
                    verify: user['verify'] ?? '',
                  ),
                )
                .toList() ??
            [],
      );
    } else {
      throw Exception('Failed to search users: ${response.statusCode}');
    }
  }
}
