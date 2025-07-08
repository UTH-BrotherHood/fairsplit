import 'package:fairsplit/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fairsplit/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import '../../domain/usecases/get_profile.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_remote_datasource.dart';

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<User>>(
      (ref) => ProfileViewModel(ref),
    );

class ProfileViewModel extends StateNotifier<AsyncValue<User>> {
  final Ref ref;
  ProfileViewModel(this.ref) : super(const AsyncLoading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(getProfileUseCaseProvider).call();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Provider cho usecase
final getProfileUseCaseProvider = Provider<GetProfile>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return GetProfile(repo);
});

// Provider cho repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ProfileRemoteDatasourceImpl();
  return ProfileRepositoryImpl(remote);
});
