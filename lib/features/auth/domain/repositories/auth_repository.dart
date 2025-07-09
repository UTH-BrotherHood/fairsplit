// Định nghĩa các interface (abstract class) cho repository.
// Repository là cầu nối giữa domain và data (data source, API, local).
// Interface này sẽ được implement ở tầng data.
import '../entities/auth.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signUp(String name, String email, String password, DateTime dob);
  Future<void> signOut();
  Future<User> signInWithGoogle();
  Future<String> refreshToken(String refreshToken);
}
