import 'package:fairsplit/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl(this.remoteDataSource);

  @override
  Future<GroupsResponse> getMyGroups({int page = 1, int limit = 10}) async {
    return await remoteDataSource.getMyGroups(page: page, limit: limit);
  }

  @override
  Future<GroupResponse> getGroup(String groupId) async {
    final response = await remoteDataSource.getGroup(groupId);
    return response.toEntity();
  }

  @override
  Future<GroupResponse> createGroup(CreateGroupRequest request) async {
    final response = await remoteDataSource.createGroup(request);
    return response.toEntity();
  }

  @override
  Future<GroupResponse> updateGroup(
    String groupId,
    UpdateGroupRequest request,
  ) async {
    final response = await remoteDataSource.updateGroup(groupId, request);
    return response.toEntity();
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    return await remoteDataSource.deleteGroup(groupId);
  }

  @override
  Future<GroupMembersResponse> getGroupMembers(String groupId) async {
    return await remoteDataSource.getGroupMembers(groupId);
  }

  @override
  Future<void> addMembers(String groupId, AddMembersRequest request) async {
    return await remoteDataSource.addMembers(groupId, request);
  }

  @override
  Future<void> updateMember(
    String groupId,
    String memberId,
    UpdateMemberRequest request,
  ) async {
    return await remoteDataSource.updateMember(groupId, memberId, request);
  }

  @override
  Future<void> deleteMember(String groupId, String memberId) async {
    return await remoteDataSource.deleteMember(groupId, memberId);
  }

  @override
  Future<UserSearchResponse> searchUsers(String query) async {
    return await remoteDataSource.searchUsers(query);
  }
}
