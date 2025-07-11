import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_detail_view_model.dart';
import 'package:fairsplit/features/groups/presentation/pages/edit_group_page.dart';
import 'package:fairsplit/features/groups/presentation/pages/group_members_page.dart';
import 'package:fairsplit/features/shopping/presentation/pages/all_shopping_lists_page.dart';

class GroupDetailPage extends ConsumerStatefulWidget {
  final String groupId;
  final String? groupName;

  const GroupDetailPage({super.key, required this.groupId, this.groupName});

  @override
  ConsumerState<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends ConsumerState<GroupDetailPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(GroupDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data if the groupId has changed
    if (oldWidget.groupId != widget.groupId) {
      ref
          .read(groupDetailViewModelProvider(widget.groupId).notifier)
          .refreshGroupDetails();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      ref
          .read(groupDetailViewModelProvider(widget.groupId).notifier)
          .refreshGroupDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupDetailState = ref.watch(
      groupDetailViewModelProvider(widget.groupId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: groupDetailState.when(
          data: (groupResponse) => Text(groupResponse.data.name),
          loading: () => Text(widget.groupName ?? 'Loading...'),
          error: (_, __) => Text(widget.groupName ?? 'Error'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(groupDetailViewModelProvider(widget.groupId).notifier)
                  .refreshGroupDetails();
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              groupDetailState.whenData((groupResponse) {
                _showGroupOptionsMenu(context, ref, groupResponse.data);
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(groupDetailViewModelProvider(widget.groupId).notifier)
              .refreshGroupDetails();
        },
        child: groupDetailState.when(
          data: (groupResponse) =>
              _buildGroupDetails(context, ref, groupResponse.data),
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(context, ref, error),
        ),
      ),
    );
  }

  Widget _buildGroupDetails(BuildContext context, WidgetRef ref, Group group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Info Card
          _buildGroupInfoCard(group),

          const SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(context, ref, group),

          const SizedBox(height: 20),

          // Recent Activities
          _buildRecentActivities(),

          const SizedBox(height: 20),

          // Members Section
          _buildMembersSection(context, group),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4A90E2)),
          SizedBox(height: 16),
          Text(
            'Đang tải thông tin nhóm...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(groupDetailViewModelProvider(widget.groupId).notifier)
                  .refreshGroupDetails();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfoCard(Group group) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF87CEEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (group.avatarUrl != null)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(group.avatarUrl!),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem('Thành viên', '${group.members.length} người'),
              const SizedBox(width: 20),
              _buildInfoItem('Tiền tệ', group.settings.currency),
              const SizedBox(width: 20),
              _buildInfoItem(
                'Trạng thái',
                group.isArchived ? 'Đã lưu trữ' : 'Hoạt động',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, Group group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add,
                label: 'Thêm chi phí',
                color: const Color(0xFF4A90E2),
                onTap: () => _handleAddExpense(context, ref, group.id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.group,
                label: 'Quản lý thành viên',
                color: const Color(0xFF50C878),
                onTap: () async {
                  // Navigate to GroupMembersPage and wait for result
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupMembersPage(groupId: group.id),
                    ),
                  );
                  // Refresh group details when returning
                  ref
                      .read(
                        groupDetailViewModelProvider(widget.groupId).notifier,
                      )
                      .refreshGroupDetails();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Center(
            child: Text(
              'Chưa có hoạt động nào',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(BuildContext context, Group group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thành viên (${group.members.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupMembersPage(groupId: widget.groupId),
                  ),
                );
                // Refresh group details when returning
                ref
                    .read(groupDetailViewModelProvider(widget.groupId).notifier)
                    .refreshGroupDetails();
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              ...group.members
                  .take(3)
                  .map((member) => _buildMemberItem(member)),
              if (group.members.length > 3) ...[
                const Divider(),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupMembersPage(groupId: widget.groupId),
                      ),
                    );
                    // Refresh group details when returning
                    ref
                        .read(
                          groupDetailViewModelProvider(widget.groupId).notifier,
                        )
                        .refreshGroupDetails();
                  },
                  child: Text(
                    'Xem thêm ${group.members.length - 3} thành viên',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberItem(GroupMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF4A90E2),
            backgroundImage: member.user.avatarUrl != null
                ? NetworkImage(member.user.avatarUrl!)
                : null,
            child: member.user.avatarUrl == null
                ? Text(
                    member.user.username.isNotEmpty
                        ? member.user.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.nickname != null && member.nickname!.isNotEmpty
                            ? '${member.nickname} (${member.user.username})'
                            : member.user.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(member.role),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getRoleDisplayName(member.role),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.user.email,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.red;
      case 'admin':
        return Colors.orange;
      case 'member':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'owner':
        return 'Chủ nhóm';
      case 'admin':
        return 'Quản trị viên';
      case 'member':
        return 'Thành viên';
      default:
        return role;
    }
  }

  Future<void> _handleAddExpense(
    BuildContext context,
    WidgetRef ref,
    String groupId,
  ) async {
    // Get current group details to get the group name
    final groupDetailState = ref.read(groupDetailViewModelProvider(groupId));
    final groupName = groupDetailState.when(
      data: (groupResponse) => groupResponse.data.name,
      loading: () => 'Loading...',
      error: (_, __) => 'Group',
    );

    // Navigate to AllShoppingListsPage and show create form for this group
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllShoppingListsPage(
          initialGroupId: groupId,
          initialGroupName: groupName,
          showCreateForm: true,
        ),
      ),
    );
  }

  void _showGroupOptionsMenu(BuildContext context, WidgetRef ref, Group group) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa nhóm'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGroupPage(group: group),
                  ),
                );

                // Refresh group details if group was updated
                if (result == true) {
                  ref
                      .read(
                        groupDetailViewModelProvider(widget.groupId).notifier,
                      )
                      .refreshGroupDetails();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Quản lý thành viên'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupMembersPage(groupId: widget.groupId),
                  ),
                );
                // Refresh group details when returning
                ref
                    .read(groupDetailViewModelProvider(widget.groupId).notifier)
                    .refreshGroupDetails();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt nhóm'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển')),
                );
              },
            ),
            if (!group.isArchived)
              ListTile(
                leading: const Icon(Icons.archive, color: Colors.orange),
                title: const Text(
                  'Lưu trữ nhóm',
                  style: TextStyle(color: Colors.orange),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Xóa nhóm',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteGroupDialog(context, ref, group);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteGroupDialog(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhóm'),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhóm "${group.name}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(groupDetailViewModelProvider(widget.groupId).notifier)
                    .deleteGroup();
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to groups list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa nhóm thành công!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
