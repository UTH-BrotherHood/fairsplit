import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/features/auth/domain/repositories/auth_repository.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fairsplit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:http/http.dart' as http;

class AuthViewModel extends StateNotifier<User?> {
  final AuthRepository repository;

  AuthViewModel(this.repository) : super(null);

  Future<void> login({required String email, required String password}) async {
    try {
      final user = await repository.login(email, password);
      state = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required DateTime dob,
  }) async {
    try {
      final user = await repository.signUp(name, email, password, dob);
      state = user;
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
    if (user != null) {
      state = user;
    }
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, User?>((
  ref,
) {
  final remoteDataSource = AuthRemoteDataSource(http.Client());
  final repository = AuthRepositoryImpl(remoteDataSource);
  return AuthViewModel(repository);
});
