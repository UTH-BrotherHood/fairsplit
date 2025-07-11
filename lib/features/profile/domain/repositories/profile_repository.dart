import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/profile/data/models/update_profile_request.dart';

abstract class ProfileRepository {
  Future<User> getProfile({bool forceRemote = false});
  Future<User> updateProfile(UpdateProfileRequest request);
}
