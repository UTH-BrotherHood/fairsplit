import 'package:fairsplit/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fairsplit/features/profile/presentation/viewmodels/profile_view_model.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Refresh profile data when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).fetchProfile();
    });
  }

  void _logout() async {
    await ref.read(authViewModelProvider.notifier).signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Don't refresh here to avoid StateNotifierListenerError
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            strokeWidth: 2,
          ),
        ),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Unable to load profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header Card
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),

                // Quick Stats
                _buildQuickStats(context, user),
                const SizedBox(height: 24),

                // Personal Information
                _buildInfoSection(
                  title: "Personal Information",
                  children: [
                    _buildInfoRow("User ID", user.id),
                    _buildInfoRow(
                      "Date of Birth",
                      user.dateOfBirth != null
                          ? _formatDate(user.dateOfBirth)
                          : "Not provided",
                    ),
                    _buildInfoRow("Member Since", _formatDate(user.createdAt)),
                  ],
                ),

                // Privacy Settings
                if (user.privacySettings != null) ...[
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: "Privacy Settings",
                    children: [
                      _buildInfoRow(
                        "Profile Visibility",
                        user.privacySettings!.profileVisibility ?? "Not set",
                      ),
                      _buildInfoRow(
                        "Friend Requests",
                        user.privacySettings!.friendRequests ?? "Not set",
                      ),
                    ],
                  ),
                ],

                // Connected Accounts
                if (user.google != null ||
                    user.facebook != null ||
                    user.twitter != null) ...[
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: "Connected Accounts",
                    children: [
                      if (user.google != null)
                        _buildInfoRow("Google", user.google!.googleId),
                      if (user.facebook != null)
                        _buildInfoRow("Facebook", user.facebook!.facebookId),
                      if (user.twitter != null)
                        _buildInfoRow("Twitter", user.twitter!.twitterId),
                    ],
                  ),
                ],

                // Preferences
                if (user.preferences != null &&
                    user.preferences!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: "Preferences",
                    children: [
                      ...user.preferences!.entries.map(
                        (e) => _buildInfoRow(
                          e.key,
                          e.value?.toString() ?? 'Not set',
                        ),
                      ),
                    ],
                  ),
                ],

                // Last Login
                if (user.lastLoginTime != null) ...[
                  const SizedBox(height: 20),
                  _buildLastLoginCard(context, user.lastLoginTime!),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF9FAFB),
                  backgroundImage:
                      user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                      ? Icon(Icons.person, size: 32, color: Colors.grey[400])
                      : null,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    context.push('/edit-profile');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),

          // Email
          if (user.email != null && user.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.email!,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Verification Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.verify == 'verified'
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: user.verify == 'verified'
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFDE68A),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.verify == 'verified'
                      ? Icons.check_circle
                      : Icons.schedule,
                  color: user.verify == 'verified'
                      ? const Color(0xFF059669)
                      : const Color(0xFFD97706),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  user.verify == 'verified' ? 'Verified' : 'Pending',
                  style: TextStyle(
                    color: user.verify == 'verified'
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Verification Type
          if (user.verificationType.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              user.verificationType,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, dynamic user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: "Friends",
            value: "${user.friends.length}",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: "Status",
            value: user.verify == 'verified' ? "Active" : "Pending",
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastLoginCard(BuildContext context, DateTime lastLogin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF4F46E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Last Login",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(lastLogin),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
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
