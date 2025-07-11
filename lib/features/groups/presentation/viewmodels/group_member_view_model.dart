import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/domain/repositories/group_repository.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Member management view model
class GroupMemberViewModel
    extends StateNotifier<AsyncValue<GroupMembersResponse>> {
  final GroupRepository repository;
  final String groupId;

  GroupMemberViewModel({required this.repository, required this.groupId})
    : super(const AsyncLoading()) {
    getGroupMembers();
  }

  Future<void> getGroupMembers() async {
    state = const AsyncLoading();
    try {
      final membersResponse = await repository.getGroupMembers(groupId);
      state = AsyncData(membersResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshMembers() async {
    await getGroupMembers();
  }

  Future<void> addMembers(AddMembersRequest request) async {
    try {
      await repository.addMembers(groupId, request);
      // Refresh members list after adding
      await getGroupMembers();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateMember(
    String memberId,
    UpdateMemberRequest request,
  ) async {
    try {
      await repository.updateMember(groupId, memberId, request);
      // Refresh members list after updating
      await getGroupMembers();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      await repository.deleteMember(groupId, memberId);
      // Refresh members list after deleting
      await getGroupMembers();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Member view model provider factory
final groupMemberViewModelProvider =
    StateNotifierProvider.family<
      GroupMemberViewModel,
      AsyncValue<GroupMembersResponse>,
      String
    >((ref, groupId) {
      final repository = ref.watch(groupRepositoryProvider);
      return GroupMemberViewModel(repository: repository, groupId: groupId);
    });

// User search view model
class UserSearchViewModel
    extends StateNotifier<AsyncValue<UserSearchResponse>> {
  final GroupRepository repository;

  UserSearchViewModel({required this.repository})
    : super(AsyncData(UserSearchResponse(message: '', users: [])));

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = AsyncData(UserSearchResponse(message: '', users: []));
      return;
    }

    state = const AsyncLoading();
    try {
      final searchResponse = await repository.searchUsers(query);
      state = AsyncData(searchResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clearSearch() {
    state = AsyncData(UserSearchResponse(message: '', users: []));
  }
}

// User search view model provider
final userSearchViewModelProvider =
    StateNotifierProvider<UserSearchViewModel, AsyncValue<UserSearchResponse>>((
      ref,
    ) {
      final repository = ref.watch(groupRepositoryProvider);
      return UserSearchViewModel(repository: repository);
    });
