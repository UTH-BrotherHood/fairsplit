import 'package:fairsplit/features/groups/domain/entities/group.dart';

abstract class GroupRepository {
  Future<GroupsResponse> getMyGroups({int page = 1, int limit = 10});
  Future<GroupResponse> createGroup(CreateGroupRequest request);
}
