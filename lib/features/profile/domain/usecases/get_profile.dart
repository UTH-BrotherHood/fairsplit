import '../repositories/profile_repository.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';

class GetProfile {
  final ProfileRepository repository;
  GetProfile(this.repository);

  Future<User> call() => repository.getProfile();
}
