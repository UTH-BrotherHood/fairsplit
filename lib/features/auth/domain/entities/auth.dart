// Chứa các class đại diện cho thực thể nghiệp vụ (business entities).
// Entities thường giống models, nhưng có thể đơn giản hơn, chỉ chứa các trường cần thiết cho nghiệp vụ.
// Không phụ thuộc vào JSON hay framework nào.
class User {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final List<String> groups;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final String verify;
  final String verificationType;
  final List<String> friends;
  final Map<String, dynamic>? preferences;
  final PrivacySettings? privacySettings;
  final GoogleAccount? google;
  final FacebookAccount? facebook;
  final TwitterAccount? twitter;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginTime;

  User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.groups = const [],
    this.dateOfBirth,
    this.avatarUrl,
    required this.verify,
    required this.verificationType,
    this.friends = const [],
    this.preferences,
    this.privacySettings,
    this.google,
    this.facebook,
    this.twitter,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginTime,
  });
}

class PrivacySettings {
  final String? profileVisibility; // 'public', 'friends', 'private'
  final String? friendRequests; // 'everyone', 'friendsOfFriends', 'none'
  final Map<String, dynamic>? extras; // other dynamic keys

  PrivacySettings({this.profileVisibility, this.friendRequests, this.extras});
}

class GoogleAccount {
  final String googleId;
  GoogleAccount({required this.googleId});
}

class FacebookAccount {
  final String facebookId;
  FacebookAccount({required this.facebookId});
}

class TwitterAccount {
  final String twitterId;
  TwitterAccount({required this.twitterId});
}
