import 'dart:convert';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/shared/services/shared_prefs_service.dart';

class ProfileLocalDatasource {
  static const String userKey = 'user_profile';

  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(_userToMap(user));
    await SharedPrefsService.setString(userKey, userJson);
  }

  User? getUser() {
    final userJson = SharedPrefsService.getString(userKey);
    if (userJson == null) return null;
    final map = jsonDecode(userJson) as Map<String, dynamic>;
    return _userFromMap(map);
  }

  static Future<void> removeUser() async {
    await SharedPrefsService.remove(userKey);
  }

  Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'email': user.email, // nullable
      'phone': user.phone, // nullable
      'groups': user.groups,
      'dateOfBirth': user.dateOfBirth.toIso8601String(),
      'avatarUrl': user.avatarUrl, // nullable
      'verify': user.verify,
      'verificationType': user.verificationType,
      'friends': user.friends,
      'preferences': user.preferences,
      'privacySettings': user.privacySettings != null
          ? {
              'profileVisibility': user.privacySettings!.profileVisibility,
              'friendRequests': user.privacySettings!.friendRequests,
              'extras':
                  user.privacySettings!.extras, // nếu cần lưu thêm key động
            }
          : null,
      'google': user.google != null
          ? {'googleId': user.google!.googleId}
          : null,
      'facebook': user.facebook != null
          ? {'facebookId': user.facebook!.facebookId}
          : null,
      'twitter': user.twitter != null
          ? {'twitterId': user.twitter!.twitterId}
          : null,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
      // Nếu có thể null, nhớ check
      'lastLoginTime': user.lastLoginTime?.toIso8601String(),
    };
  }

  User _userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'],
      phone: map['phone'],
      groups: (map['groups'] as List?)?.map((e) => e.toString()).toList() ?? [],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      avatarUrl: map['avatarUrl'],
      verify: map['verify'] ?? 'unverified',
      verificationType: map['verificationType'] ?? 'email',
      friends:
          (map['friends'] as List?)?.map((e) => e.toString()).toList() ?? [],
      preferences: map['preferences'] != null
          ? Map<String, dynamic>.from(map['preferences'])
          : null,
      privacySettings: map['privacySettings'] != null
          ? PrivacySettings(
              profileVisibility: map['privacySettings']['profileVisibility'],
              friendRequests: map['privacySettings']['friendRequests'],
              extras: map['privacySettings']['extras'],
            )
          : null,
      google: map['google'] != null
          ? GoogleAccount(googleId: map['google']['googleId'])
          : null,
      facebook: map['facebook'] != null
          ? FacebookAccount(facebookId: map['facebook']['facebookId'])
          : null,
      twitter: map['twitter'] != null
          ? TwitterAccount(twitterId: map['twitter']['twitterId'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      lastLoginTime: map['lastLoginTime'] != null
          ? DateTime.tryParse(map['lastLoginTime'])
          : null,
    );
  }
}
