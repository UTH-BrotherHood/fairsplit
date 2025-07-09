import 'package:fairsplit/shared/services/shared_prefs_service.dart';
// import 'package:fairsplit/features/auth/domain/entities/auth.dart';

// 1. Chức năng:
// Đây là nơi xử lý lưu trữ dữ liệu xác thực (auth) ở local device, ví dụ: token, thông tin user, refresh token, v.v.
// Thường sử dụng các package như shared_preferences, hive, hoặc secure_storage để lưu trữ.
// Không gọi API ở đây, chỉ thao tác với bộ nhớ cục bộ.
// 2. Ví dụ chức năng:
// Lưu access token sau khi đăng nhập thành công.
// Đọc access token để gửi kèm các request.
// Xóa token khi logout.
class AuthLocalDataSource {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await SharedPrefsService.setString(accessTokenKey, accessToken);
    await SharedPrefsService.setString(refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    String? accessToken = SharedPrefsService.getString(accessTokenKey);
    return accessToken;
  }

  Future<String?> getRefreshToken() async {
    return SharedPrefsService.getString(refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await SharedPrefsService.remove(accessTokenKey);
    await SharedPrefsService.remove(refreshTokenKey);
  }

  // Future<void> saveUser(User user) async {
  //   await SharedPrefsService.setString('user_id', user.id);
  //   await SharedPrefsService.setString('username', user.username);
  //   await SharedPrefsService.setString('email', user.email);
  //   await SharedPrefsService.setString('phone', user.phone ?? '');
  //   await SharedPrefsService.setString('groups', user.groups?.join(',') ?? '');
  //   await SharedPrefsService.setString('dateOfBirth', user.dateOfBirth ?? '');
  //   await SharedPrefsService.setString('avatarUrl', user.avatarUrl ?? '');
  //   await SharedPrefsService.setString('verify', user.verify ?? '');
  //   await SharedPrefsService.setString(
  //     'verificationType',
  //     user.verificationType ?? '',
  //   );
  //   await SharedPrefsService.setString(
  //     'friends',
  //     user.friends?.join(',') ?? '',
  //   );
  //   await SharedPrefsService.setString(
  //     'preferences',
  //     user.preferences != null ? user.preferences.toString() : '',
  //   );
  //   await SharedPrefsService.setString(
  //     'privacySettings',
  //     user.privacySettings != null ? user.privacySettings.toString() : '',
  //   );
  //   await SharedPrefsService.setString('google', user.google?.toString() ?? '');
  //   await SharedPrefsService.setString(
  //     'facebook',
  //     user.facebook?.toString() ?? '',
  //   );
  //   await SharedPrefsService.setString(
  //     'twitter',
  //     user.twitter?.toString() ?? '',
  //   );
  //   await SharedPrefsService.setString('createdAt', user.createdAt ?? '');
  //   await SharedPrefsService.setString('updatedAt', user.updatedAt ?? '');
  //   await SharedPrefsService.setString(
  //     'lastLoginTime',
  //     user.lastLoginTime ?? '',
  //   );
  // }

  // Future<User?> getUser() async {
  //   final id = SharedPrefsService.getString('user_id');
  //   final username = SharedPrefsService.getString('username');
  //   final email = SharedPrefsService.getString('email');
  //   if (id != null && username != null && email != null) {
  //     return User(
  //       id: id,
  //       username: username,
  //       email: email,
  //       phone: SharedPrefsService.getString('phone'),
  //       groups: SharedPrefsService.getString(
  //         'groups',
  //       )?.split(',').where((e) => e.isNotEmpty).toList(),
  //       dateOfBirth: SharedPrefsService.getString('dateOfBirth'),
  //       avatarUrl: SharedPrefsService.getString('avatarUrl'),
  //       verify: SharedPrefsService.getString('verify'),
  //       verificationType: SharedPrefsService.getString('verificationType'),
  //       friends: SharedPrefsService.getString(
  //         'friends',
  //       )?.split(',').where((e) => e.isNotEmpty).toList(),
  //       blockedUsers: SharedPrefsService.getString(
  //         'blockedUsers',
  //       )?.split(',').where((e) => e.isNotEmpty).toList(),
  //       preferences: null, // Nếu muốn parse lại Map thì cần convert từ String
  //       privacySettings:
  //           null, // Nếu muốn parse lại Map thì cần convert từ String
  //       google: SharedPrefsService.getString('google'),
  //       facebook: SharedPrefsService.getString('facebook'),
  //       twitter: SharedPrefsService.getString('twitter'),
  //       createdAt: SharedPrefsService.getString('createdAt'),
  //       updatedAt: SharedPrefsService.getString('updatedAt'),
  //       lastLoginTime: SharedPrefsService.getString('lastLoginTime'),
  //     );
  //   }
  //   return null;
  // }

  // Future<void> clearUser() async {
  //   await SharedPrefsService.remove('user_id');
  //   await SharedPrefsService.remove('username');
  //   await SharedPrefsService.remove('email');
  //   await SharedPrefsService.remove('phone');
  //   await SharedPrefsService.remove('groups');
  //   await SharedPrefsService.remove('dateOfBirth');
  //   await SharedPrefsService.remove('avatarUrl');
  //   await SharedPrefsService.remove('verify');
  //   await SharedPrefsService.remove('verificationType');
  //   await SharedPrefsService.remove('friends');
  //   await SharedPrefsService.remove('preferences');
  //   await SharedPrefsService.remove('privacySettings');
  //   await SharedPrefsService.remove('google');
  //   await SharedPrefsService.remove('facebook');
  //   await SharedPrefsService.remove('twitter');
  //   await SharedPrefsService.remove('createdAt');
  //   await SharedPrefsService.remove('updatedAt');
  //   await SharedPrefsService.remove('lastLoginTime');
  // }
}
