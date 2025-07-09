import 'package:fairsplit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/auth/data/models/auth_response_model.dart';
import 'package:fairsplit/features/auth/data/models/user_model.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/auth/domain/repositories/auth_repository.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<User> login(String email, String password) async {
    final AuthResponseModel response = await remoteDataSource.login(
      email,
      password,
    );

    await localDataSource.saveTokens(
      response.data.accessToken,
      response.data.refreshToken,
    );

    final userModel = response.data.user;
    return userModel.toEntity();
  }

  @override
  Future<User> signUp(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    final AuthResponseModel response = await remoteDataSource.signUp(
      name,
      email,
      password,
      dob,
    );
    await localDataSource.saveTokens(
      response.data.accessToken,
      response.data.refreshToken,
    );

    final userModel = UserModel.fromJson(
      response.data.user as Map<String, dynamic>,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearTokens();
    await ProfileLocalDatasource.removeUser();
  }

  @override
  Future<User> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    final response = await remoteDataSource.refreshToken(refreshToken);
    await localDataSource.saveTokens(
      response.data.accessToken,
      response.data.refreshToken,
    );
    return response.data.accessToken;
  }
}
