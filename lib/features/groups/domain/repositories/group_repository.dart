import 'package:fairsplit/features/groups/domain/entities/group.dart';

abstract class GroupRepository {
  // Group management
  Future<GroupsResponse> getMyGroups({int page = 1, int limit = 10});
  Future<GroupResponse> getGroup(String groupId);
  Future<GroupResponse> createGroup(CreateGroupRequest request);
  Future<GroupResponse> updateGroup(String groupId, UpdateGroupRequest request);
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
