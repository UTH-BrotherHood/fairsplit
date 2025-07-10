import 'package:fairsplit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/auth/data/models/auth_response_model.dart';
import 'package:fairsplit/features/auth/data/models/register_response_model.dart';
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
  Future<User> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required DateTime dateOfBirth,
    String verificationType = 'email',
  }) async {
    final RegisterResponseModel response = await remoteDataSource.signUp(
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      dateOfBirth: dateOfBirth,
      verificationType: verificationType,
    );

    // Don't save tokens for registration since user needs to verify email first
    // await localDataSource.saveTokens(
    //   response.data.accessToken,
    //   response.data.refreshToken,
    // );

    return response.data.user.toEntity();
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
