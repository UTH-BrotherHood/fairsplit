import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/profile/domain/repositories/profile_repository.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;
  ProfileRepositoryImpl(this.remoteDatasource);

  @override
  Future<User> getProfile() {
    return remoteDatasource.fetchProfile();
  }
}
