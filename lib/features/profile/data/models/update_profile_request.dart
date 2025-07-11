import 'dart:io';

class UpdateProfileRequest {
  final String? username;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? avatar;
  final File? avatarFile;
  final Map<String, dynamic>? preferences;
  final PrivacySettingsRequest? privacySettings;

  UpdateProfileRequest({
    this.username,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.avatar,
    this.avatarFile,
    this.preferences,
    this.privacySettings,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (dateOfBirth != null)
      data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (avatar != null) data['avatar'] = avatar;
    if (preferences != null) data['preferences'] = preferences;
    if (privacySettings != null)
      data['privacySettings'] = privacySettings!.toJson();

    return data;
  }

  bool get hasAvatarFile => avatarFile != null;
}

class PrivacySettingsRequest {
  final String? profileVisibility;
  final String? friendRequests;
  final Map<String, dynamic>? extras;

  PrivacySettingsRequest({
    this.profileVisibility,
    this.friendRequests,
    this.extras,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (profileVisibility != null)
      data['profileVisibility'] = profileVisibility;
    if (friendRequests != null) data['friendRequests'] = friendRequests;
    if (extras != null) data['extras'] = extras;

    return data;
  }
}
