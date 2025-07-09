import 'package:fairsplit/features/auth/domain/entities/auth.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile();
}
