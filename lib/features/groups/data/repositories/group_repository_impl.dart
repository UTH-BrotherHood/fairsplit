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
}
