import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/auth/domain/repositories/auth_repository.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:http/http.dart' as http;
// import 'package:jwt_decoder/jwt_decoder.dart';

class AuthViewModel extends StateNotifier<User?> {
  final AuthRepository repository;
  final AuthLocalDataSource localDataSource;

  AuthViewModel(this.repository, this.localDataSource) : super(null) {
    // _autoLogin();
  }

  // Future<void> _autoLogin() async {
  //   final accessToken = await localDataSource.getAccessToken();
  //   if (accessToken != null &&
  //       accessToken.isNotEmpty &&
  //       !JwtDecoder.isExpired(accessToken)) {
  //     state = User(id: 'dummy', username: 'dummy', email: 'dummy@email.com');
  //   } else {
  //     state = null;
  //   }
  // }

  Future<void> login({required String email, required String password}) async {
    final user = await repository.login(email, password);
    state = user;
  }

  Future<void> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required DateTime dateOfBirth,
    String verificationType = 'email',
  }) async {
    try {
      await repository.signUp(
        email: email,
        username: username,
        password: password,
        confirmPassword: confirmPassword,
        dateOfBirth: dateOfBirth,
        verificationType: verificationType,
      );
      // Don't set state for registration since user needs to verify email first
      // state = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await repository.signOut();
    state = null;
  }

  Future<void> signInWithGoogle() async {
    final user = await repository.signInWithGoogle();
    state = user;
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, User?>((
  ref,
) {
  final remoteDataSource = AuthRemoteDataSource(http.Client());
  final localDataSource = AuthLocalDataSource();
  final repository = AuthRepositoryImpl(remoteDataSource, localDataSource);
  return AuthViewModel(repository, localDataSource);
});
