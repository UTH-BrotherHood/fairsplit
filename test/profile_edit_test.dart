import 'package:flutter_test/flutter_test.dart';
import 'package:fairsplit/features/profile/data/models/update_profile_request.dart';

void main() {
  group('UpdateProfileRequest Tests', () {
    test('should create UpdateProfileRequest with all fields', () {
      final request = UpdateProfileRequest(
        username: 'testuser',
        email: 'test@example.com',
        phone: '+1234567890',
        dateOfBirth: DateTime(1990, 1, 1),
        avatar: 'https://example.com/avatar.jpg',
        preferences: {'theme': 'dark'},
        privacySettings: PrivacySettingsRequest(
          profileVisibility: 'public',
          friendRequests: 'everyone',
        ),
      );

      expect(request.username, 'testuser');
      expect(request.email, 'test@example.com');
      expect(request.phone, '+1234567890');
      expect(request.dateOfBirth, DateTime(1990, 1, 1));
      expect(request.avatar, 'https://example.com/avatar.jpg');
      expect(request.preferences, {'theme': 'dark'});
      expect(request.privacySettings?.profileVisibility, 'public');
      expect(request.privacySettings?.friendRequests, 'everyone');
    });

    test('should convert to JSON correctly', () {
      final request = UpdateProfileRequest(
        username: 'testuser',
        email: 'test@example.com',
        phone: '+1234567890',
        dateOfBirth: DateTime(1990, 1, 1),
        privacySettings: PrivacySettingsRequest(
          profileVisibility: 'public',
          friendRequests: 'everyone',
        ),
      );

      final json = request.toJson();

      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['phone'], '+1234567890');
      expect(json['dateOfBirth'], '1990-01-01T00:00:00.000');
      expect(json['privacySettings']['profileVisibility'], 'public');
      expect(json['privacySettings']['friendRequests'], 'everyone');
    });

    test('should handle null values in JSON conversion', () {
      final request = UpdateProfileRequest(
        username: 'testuser',
        // Other fields are null
      );

      final json = request.toJson();

      expect(json['username'], 'testuser');
      expect(json.containsKey('email'), false);
      expect(json.containsKey('phone'), false);
      expect(json.containsKey('dateOfBirth'), false);
      expect(json.containsKey('avatarUrl'), false);
      expect(json.containsKey('preferences'), false);
      expect(json.containsKey('privacySettings'), false);
    });
  });

  group('PrivacySettingsRequest Tests', () {
    test('should create PrivacySettingsRequest with all fields', () {
      final settings = PrivacySettingsRequest(
        profileVisibility: 'public',
        friendRequests: 'everyone',
        extras: {'custom': 'value'},
      );

      expect(settings.profileVisibility, 'public');
      expect(settings.friendRequests, 'everyone');
      expect(settings.extras, {'custom': 'value'});
    });

    test('should convert to JSON correctly', () {
      final settings = PrivacySettingsRequest(
        profileVisibility: 'public',
        friendRequests: 'everyone',
        extras: {'custom': 'value'},
      );

      final json = settings.toJson();

      expect(json['profileVisibility'], 'public');
      expect(json['friendRequests'], 'everyone');
      expect(json['extras']['custom'], 'value');
    });

    test('should handle null values in JSON conversion', () {
      final settings = PrivacySettingsRequest(
        profileVisibility: 'public',
        // Other fields are null
      );

      final json = settings.toJson();

      expect(json['profileVisibility'], 'public');
      expect(json.containsKey('friendRequests'), false);
      expect(json.containsKey('extras'), false);
    });
  });
}
