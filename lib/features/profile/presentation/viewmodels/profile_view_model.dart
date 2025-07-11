import 'package:fairsplit/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fairsplit/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:fairsplit/features/profile/data/models/update_profile_request.dart';
import 'package:http/http.dart' as http;

// Provider cho repository (inject dependences)
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ProfileRemoteDatasourceImpl(client: http.Client());
  final local = ProfileLocalDatasource();
  return ProfileRepositoryImpl(remote, local);
});

// ViewModel StateNotifier
class ProfileViewModel extends StateNotifier<AsyncValue<User>> {
  final ProfileRepository repository;
  ProfileViewModel({required this.repository}) : super(const AsyncLoading()) {
    fetchProfile();
  }

  Future<void> fetchProfile({bool forceRemote = false}) async {
    state = const AsyncLoading();
    try {
      final user = await repository.getProfile(forceRemote: forceRemote);
      print('[ProfileViewModel] fetchProfile success: $user');
      state = AsyncData(user);
    } catch (e, st) {
      print('[ProfileViewModel] fetchProfile error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> updateProfile(UpdateProfileRequest request) async {
    try {
      await repository.updateProfile(request);
      print('[ProfileViewModel] updateProfile success');
      // Sau khi update, luôn fetch lại từ server để cập nhật giao diện
      await fetchProfile(forceRemote: true);
    } catch (e, st) {
      print('[ProfileViewModel] updateProfile error: $e');
      state = AsyncError(e, st);
      rethrow; // Re-throw to let the UI handle the error
    }
  }
}

// ViewModel provider (inject repo vào ViewModel)
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<User>>((ref) {
      final repo = ref.watch(profileRepositoryProvider);
      return ProfileViewModel(repository: repo);
    });
