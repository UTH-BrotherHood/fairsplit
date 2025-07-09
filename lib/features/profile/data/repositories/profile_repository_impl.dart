import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/profile/domain/repositories/profile_repository.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;
  final ProfileLocalDatasource localDatasource;
  ProfileRepositoryImpl(this.remoteDatasource, this.localDatasource);

  @override
  Future<User> getProfile() async {
    final user = localDatasource.getUser();
    if (user != null) {
      return user;
    }
    final remoteUser = await remoteDatasource.fetchProfile();
    await localDatasource.saveUser(remoteUser);
    return remoteUser;
  }

  @override
  Future<User> updateProfile() async {
    final user = await remoteDatasource.fetchProfile();
    await localDatasource.saveUser(user);
    return user;
  }
}
