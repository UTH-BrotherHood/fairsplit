import 'package:fairsplit/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fairsplit/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_local_datasource.dart';
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

  Future<void> fetchProfile() async {
    state = const AsyncLoading();
    try {
      final user = await repository.getProfile();
      print('[ProfileViewModel] fetchProfile success: $user');
      state = AsyncData(user);
    } catch (e, st) {
      print('[ProfileViewModel] fetchProfile error: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> updateProfile() async {
    state = const AsyncLoading();
    try {
      final user = await repository.updateProfile();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// ViewModel provider (inject repo vào ViewModel)
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<User>>((ref) {
      final repo = ref.watch(profileRepositoryProvider);
      return ProfileViewModel(repository: repo);
    });
