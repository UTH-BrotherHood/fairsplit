// auth_repository.dart: interface và implementation.

import 'package:fairsplit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    return User(id: userModel.id, name: userModel.name);
  }

  @override
  Future<User> signUp(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    final userModel = await remoteDataSource.signUp(name, email, password, dob);
    return User(id: userModel.id, name: userModel.name);
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    // Gọi API backend để logout nếu cần
  }

  @override
  Future<void> signInWithGoogle() async {
    await remoteDataSource.signOut();
  }
}
