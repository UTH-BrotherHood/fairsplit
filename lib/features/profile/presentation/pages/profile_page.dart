import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Avatar, username, email, verify
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage:
                            user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child:
                            (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                            ? Icon(Icons.person, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (user.email != null && user.email!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            user.email!,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            user.verify == 'verified'
                                ? Icons.verified
                                : Icons.verified_outlined,
                            color: user.verify == 'verified'
                                ? Colors.blue
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.verify == 'verified'
                                ? 'Verified'
                                : 'Unverified',
                            style: TextStyle(
                              color: user.verify == 'verified'
                                  ? Colors.blue
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (user.verificationType.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(user.verificationType),
                              labelStyle: const TextStyle(fontSize: 12),
                              backgroundColor: Colors.blue[50],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Thông tin cá nhân
                _ProfileSection(
                  title: "Personal Info",
                  children: [
                    _ProfileField(label: "ID", value: user.id),
                    _ProfileField(
                      label: "Date of Birth",
                      value: user.dateOfBirth != null
                          ? _formatDate(user.dateOfBirth)
                          : "-",
                    ),
                    _ProfileField(label: "Phone", value: user.phone ?? "-"),
                    // _ProfileField(
                    //   label: "Groups",
                    //   value: user.groups.isNotEmpty
                    //       ? user.groups.join(", ")
                    //       : "-",
                    // ),
                    _ProfileField(
                      label: "Account Created",
                      value: _formatDate(user.createdAt),
                    ),
                  ],
                ),

                // Privacy settings
                if (user.privacySettings != null) ...[
                  const SizedBox(height: 16),
                  _ProfileSection(
                    title: "Privacy Settings",
                    children: [
                      _ProfileField(
                        label: "Profile Visibility",
                        value: user.privacySettings!.profileVisibility ?? "-",
                      ),
                      _ProfileField(
                        label: "Friend Requests",
                        value: user.privacySettings!.friendRequests ?? "-",
                      ),
                    ],
                  ),
                ],

                // Social
                if (user.google != null ||
                    user.facebook != null ||
                    user.twitter != null) ...[
                  const SizedBox(height: 16),
                  _ProfileSection(
                    title: "Connected Accounts",
                    children: [
                      if (user.google != null)
                        _ProfileField(
                          label: "Google",
                          value: user.google!.googleId,
                        ),
                      if (user.facebook != null)
                        _ProfileField(
                          label: "Facebook",
                          value: user.facebook!.facebookId,
                        ),
                      if (user.twitter != null)
                        _ProfileField(
                          label: "Twitter",
                          value: user.twitter!.twitterId,
                        ),
                    ],
                  ),
                ],

                // Friends & Blocked users
                const SizedBox(height: 16),
                _ProfileSection(
                  title: "Social",
                  children: [
                    _ProfileField(
                      label: "Friends",
                      value: user.friends.length.toString(),
                    ),
                  ],
                ),

                // Preferences (hiển thị dạng json nếu có)
                if (user.preferences != null &&
                    user.preferences!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ProfileSection(
                    title: "Preferences",
                    children: [
                      ...user.preferences!.entries.map(
                        (e) => _ProfileField(
                          label: e.key,
                          value: e.value?.toString() ?? '-',
                        ),
                      ),
                    ],
                  ),
                ],

                // Last login time
                if (user.lastLoginTime != null) ...[
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: "Last Login",
                    value: _formatDate(user.lastLoginTime!),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Section widget
class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }
}

/// Field widget
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.black87)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return "-";
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}
