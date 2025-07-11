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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.grey),
              onPressed: () {
                context.push('/settings');
              },
            ),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Card with Avatar and Basic Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar with gradient border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 47,
                            backgroundImage:
                                user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child:
                                (user.avatarUrl == null ||
                                    user.avatarUrl!.isEmpty)
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Username
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                      ),

                      // Email
                      if (user.email != null && user.email!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            user.email!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Verification Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: user.verify == 'verified'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: user.verify == 'verified'
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.verify == 'verified'
                                  ? Icons.verified
                                  : Icons.schedule,
                              color: user.verify == 'verified'
                                  ? Colors.green
                                  : Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.verify == 'verified'
                                  ? 'Verified'
                                  : 'Pending Verification',
                              style: TextStyle(
                                color: user.verify == 'verified'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Verification Type
                      if (user.verificationType.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            user.verificationType,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Personal Info Section
                _ModernProfileSection(
                  title: "Personal Information",
                  icon: Icons.person_outline,
                  children: [
                    _ModernProfileField(
                      icon: Icons.badge_outlined,
                      label: "User ID",
                      value: user.id,
                    ),
                    _ModernProfileField(
                      icon: Icons.cake_outlined,
                      label: "Date of Birth",
                      value: user.dateOfBirth != null
                          ? _formatDate(user.dateOfBirth)
                          : "Not provided",
                    ),
                    _ModernProfileField(
                      icon: Icons.calendar_today_outlined,
                      label: "Member Since",
                      value: _formatDate(user.createdAt),
                    ),
                  ],
                ),

                // Privacy Settings
                if (user.privacySettings != null) ...[
                  const SizedBox(height: 16),
                  _ModernProfileSection(
                    title: "Privacy Settings",
                    icon: Icons.privacy_tip_outlined,
                    children: [
                      _ModernProfileField(
                        icon: Icons.visibility_outlined,
                        label: "Profile Visibility",
                        value:
                            user.privacySettings!.profileVisibility ??
                            "Not set",
                      ),
                      _ModernProfileField(
                        icon: Icons.people_outline,
                        label: "Friend Requests",
                        value:
                            user.privacySettings!.friendRequests ?? "Not set",
                      ),
                    ],
                  ),
                ],

                // Connected Accounts
                if (user.google != null ||
                    user.facebook != null ||
                    user.twitter != null) ...[
                  const SizedBox(height: 16),
                  _ModernProfileSection(
                    title: "Connected Accounts",
                    icon: Icons.link_outlined,
                    children: [
                      if (user.google != null)
                        _ModernProfileField(
                          icon: Icons.g_mobiledata,
                          label: "Google",
                          value: user.google!.googleId,
                          valueColor: Colors.red,
                        ),
                      if (user.facebook != null)
                        _ModernProfileField(
                          icon: Icons.facebook,
                          label: "Facebook",
                          value: user.facebook!.facebookId,
                          valueColor: Colors.blue,
                        ),
                      if (user.twitter != null)
                        _ModernProfileField(
                          icon: Icons.alternate_email,
                          label: "Twitter",
                          value: user.twitter!.twitterId,
                          valueColor: Colors.lightBlue,
                        ),
                    ],
                  ),
                ],

                // Social Stats
                const SizedBox(height: 16),
                _ModernProfileSection(
                  title: "Social",
                  icon: Icons.groups_outlined,
                  children: [
                    _ModernProfileField(
                      icon: Icons.group_outlined,
                      label: "Friends",
                      value: "${user.friends.length} friends",
                      valueColor: Colors.green,
                    ),
                  ],
                ),

                // Preferences
                if (user.preferences != null &&
                    user.preferences!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ModernProfileSection(
                    title: "Preferences",
                    icon: Icons.tune_outlined,
                    children: [
                      ...user.preferences!.entries.map(
                        (e) => _ModernProfileField(
                          icon: Icons.settings_outlined,
                          label: e.key,
                          value: e.value?.toString() ?? 'Not set',
                        ),
                      ),
                    ],
                  ),
                ],

                // Last Login
                if (user.lastLoginTime != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.access_time,
                            color: Colors.purple[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Last Login",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(user.lastLoginTime!),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Modern Section Widget
class _ModernProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ModernProfileSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue[600], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Modern Field Widget
class _ModernProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ModernProfileField({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
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
