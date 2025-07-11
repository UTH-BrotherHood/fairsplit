import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/domain/repositories/group_repository.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Group detail view model
class GroupDetailViewModel extends StateNotifier<AsyncValue<GroupResponse>> {
  final GroupRepository repository;
  final String groupId;

  GroupDetailViewModel({required this.repository, required this.groupId})
    : super(const AsyncLoading()) {
    getGroupDetails();
  }

  Future<void> getGroupDetails() async {
    state = const AsyncLoading();
    try {
      final groupResponse = await repository.getGroup(groupId);
      state = AsyncData(groupResponse);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshGroupDetails() async {
    await getGroupDetails();
  }

  Future<void> updateGroup(UpdateGroupRequest request) async {
    try {
      await repository.updateGroup(groupId, request);
      // Refresh group details after updating
      await getGroupDetails();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteGroup() async {
    try {
      await repository.deleteGroup(groupId);
      // After deletion, we don't need to update state since user will navigate back
    } catch (e) {
      rethrow;
    }
  }
}

// Group detail view model provider factory
final groupDetailViewModelProvider =
    StateNotifierProvider.family<
      GroupDetailViewModel,
      AsyncValue<GroupResponse>,
      String
    >((ref, groupId) {
      final repository = ref.watch(groupRepositoryProvider);
      return GroupDetailViewModel(repository: repository, groupId: groupId);
    });
