import 'package:fairsplit/features/auth/domain/entities/auth.dart';

abstract class ProfileRemoteDatasource {
  Future<User> fetchProfile();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  @override
  Future<User> fetchProfile() async {
    // Trả về user giả lập chỉ có id và name
    return User(id: '1', name: 'Demo User');
  }
}
