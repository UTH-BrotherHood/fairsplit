import 'package:fairsplit/features/auth/domain/entities/auth.dart';

class UserModel {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final List<String> groups;
  final DateTime dateOfBirth;
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

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.groups = const [],
    required this.dateOfBirth,
    this.avatarUrl,
    required this.verify,
    required this.verificationType,
    this.friends = const [],
    // this.blockedUsers = const [],
    this.preferences,
    this.privacySettings,
    this.google,
    this.facebook,
    this.twitter,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? '').toString(),
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      groups:
          (json['groups'] as List?)?.map((e) => e.toString()).toList() ?? [],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
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
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
