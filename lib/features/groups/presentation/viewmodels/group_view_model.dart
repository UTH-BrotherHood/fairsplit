import 'package:fairsplit/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:fairsplit/features/groups/data/repositories/group_repository_impl.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/domain/repositories/group_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Provider cho repository
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final remoteDataSource = GroupRemoteDataSourceImpl(client: http.Client());
  return GroupRepositoryImpl(remoteDataSource);
});

// ViewModel StateNotifier
class GroupViewModel extends StateNotifier<AsyncValue<GroupsResponse>> {
  final GroupRepository repository;

  GroupViewModel({required this.repository}) : super(const AsyncLoading()) {
    getMyGroups();
  }

  Future<void> getMyGroups({int page = 1, int limit = 10}) async {
    state = const AsyncLoading();
    try {
      final groupsResponse = await repository.getMyGroups(
        page: page,
        limit: limit,
      );
      state = AsyncData(groupsResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshGroups() async {
    await getMyGroups();
  }

  Future<void> createGroup(CreateGroupRequest request) async {
    try {
      await repository.createGroup(request);
      // Refresh the groups list after creating
      await getMyGroups();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateGroup(String groupId, UpdateGroupRequest request) async {
    try {
      await repository.updateGroup(groupId, request);
      // Refresh the groups list after updating
      await getMyGroups();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await repository.deleteGroup(groupId);
      // Refresh the groups list after deleting
      await getMyGroups();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  Future<UserSearchResponse> searchUsers(String query) async {
    try {
      return await repository.searchUsers(query);
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}

// ViewModel provider
final groupViewModelProvider =
    StateNotifierProvider<GroupViewModel, AsyncValue<GroupsResponse>>((ref) {
      final repo = ref.watch(groupRepositoryProvider);
      return GroupViewModel(repository: repo);
    });
