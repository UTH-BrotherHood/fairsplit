// Chứa các class đại diện cho từng nghiệp vụ cụ thể (mỗi usecase là một chức năng).
// Mỗi usecase chỉ làm một việc, ví dụ: Login, SignUp, Logout.
// Usecase sẽ gọi repository để thực hiện nghiệp vụ.

import 'package:fairsplit/features/auth/domain/entities/auth.dart' as domain;
import 'package:fairsplit/features/auth/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;
  Login(this.repository);

  Future<domain.User> call(String email, String password) {
    return repository.login(email, password);
  }
}
