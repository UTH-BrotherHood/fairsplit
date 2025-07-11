import 'package:fairsplit/features/auth/domain/entities/auth.dart';

class UserModel {
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
  final PrivacySettingsModel? privacySettings;
  final GoogleModel? google;
  final FacebookModel? facebook;
  final TwitterModel? twitter;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginTime;

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB ObjectId format
    String parseId(dynamic idValue) {
      if (idValue is Map && idValue.containsKey('\$oid')) {
        return idValue['\$oid'].toString();
      }
      return idValue.toString();
    }

    // Handle MongoDB Date format
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is Map && dateValue.containsKey('\$date')) {
        return DateTime.parse(dateValue['\$date']);
      }
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      return null;
    }

    return UserModel(
      id: parseId(json['_id']),
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      groups: (json['groups'] as List?)?.map((e) => parseId(e)).toList() ?? [],
      dateOfBirth: parseDate(json['dateOfBirth']),
      avatarUrl: json['avatarUrl'],
      verify: json['verify'] ?? 'unverified',
      verificationType: json['verificationType'] ?? 'email',
      friends:
          (json['friends'] as List?)?.map((e) => e.toString()).toList() ?? [],
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : null,
      privacySettings: json['privacySettings'] != null
          ? PrivacySettingsModel.fromJson(
              Map<String, dynamic>.from(json['privacySettings']),
            )
          : null,
      google: json['google'] != null
          ? GoogleModel.fromJson(Map<String, dynamic>.from(json['google']))
          : null,
      facebook: json['facebook'] != null
          ? FacebookModel.fromJson(Map<String, dynamic>.from(json['facebook']))
          : null,
      twitter: json['twitter'] != null
          ? TwitterModel.fromJson(Map<String, dynamic>.from(json['twitter']))
          : null,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']) ?? DateTime.now(),
      lastLoginTime: parseDate(json['lastLoginTime']),
    );
  }

  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    phone: phone,
    groups: groups,
    dateOfBirth: dateOfBirth,
    avatarUrl: avatarUrl,
    verify: verify,
    verificationType: verificationType,
    friends: friends,
    preferences: preferences,
    privacySettings: privacySettings?.toEntity(),
    google: google?.toEntity(),
    facebook: facebook?.toEntity(),
    twitter: twitter?.toEntity(),
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastLoginTime: lastLoginTime,
  );
}

class PrivacySettingsModel {
  final String? profileVisibility;
  final String? friendRequests;
  final Map<String, dynamic>? extras;

  PrivacySettingsModel({
    this.profileVisibility,
    this.friendRequests,
    this.extras,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      profileVisibility: json['profileVisibility'],
      friendRequests: json['friendRequests'],
      extras: json,
    );
  }

  PrivacySettings toEntity() => PrivacySettings(
    profileVisibility: profileVisibility,
    friendRequests: friendRequests,
    extras: extras,
  );
}

// Các account mạng xã hội, nếu backend có thể null
class GoogleModel {
  final String googleId;
  GoogleModel({required this.googleId});
  factory GoogleModel.fromJson(Map<String, dynamic> json) =>
      GoogleModel(googleId: json['googleId']);
  GoogleAccount toEntity() => GoogleAccount(googleId: googleId);
}

class FacebookModel {
  final String facebookId;
  FacebookModel({required this.facebookId});
  factory FacebookModel.fromJson(Map<String, dynamic> json) =>
      FacebookModel(facebookId: json['facebookId']);
  FacebookAccount toEntity() => FacebookAccount(facebookId: facebookId);
}

class TwitterModel {
  final String twitterId;
  TwitterModel({required this.twitterId});
  factory TwitterModel.fromJson(Map<String, dynamic> json) =>
      TwitterModel(twitterId: json['twitterId']);
  TwitterAccount toEntity() => TwitterAccount(twitterId: twitterId);
}
