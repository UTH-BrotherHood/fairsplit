import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_member_view_model.dart';

class GroupMembersPage extends ConsumerWidget {
  final String groupId;

  const GroupMembersPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersState = ref.watch(groupMemberViewModelProvider(groupId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thành viên nhóm'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(groupMemberViewModelProvider(groupId).notifier)
                  .refreshMembers();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(groupMemberViewModelProvider(groupId).notifier)
              .refreshMembers();
        },
        child: membersState.when(
          data: (membersResponse) =>
              _buildMembersList(context, ref, membersResponse.result),
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(context, ref, error),
        ),
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
            'Đang tải danh sách thành viên...',
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
                  .read(groupMemberViewModelProvider(groupId).notifier)
                  .refreshMembers();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(
    BuildContext context,
    WidgetRef ref,
    List<GroupMember> members,
  ) {
    if (members.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có thành viên nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberItem(context, ref, member);
      },
    );
  }

  Widget _buildMemberItem(
    BuildContext context,
    WidgetRef ref,
    GroupMember member,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(member.role),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRoleDisplayName(member.role),
                        style: const TextStyle(
                          fontSize: 11,
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (member.user.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.user.phone,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Tham gia: ${_formatDate(member.joinedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) =>
                _handleMemberAction(context, ref, member, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              if (member.role != 'owner') // Can't remove owner
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa khỏi nhóm'),
                    ],
                  ),
                ),
            ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMemberAction(
    BuildContext context,
    WidgetRef ref,
    GroupMember member,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditMemberDialog(context, ref, member);
        break;
      case 'remove':
        _showRemoveMemberDialog(context, ref, member);
        break;
    }
  }

  void _showEditMemberDialog(
    BuildContext context,
    WidgetRef ref,
    GroupMember member,
  ) {
    final nicknameController = TextEditingController(
      text: member.nickname ?? '',
    );
    String selectedRole = member.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chỉnh sửa thành viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Biệt danh',
                  hintText: 'Nhập biệt danh (không bắt buộc)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                items: [
                  if (member.role == 'owner') // Owner can't change their role
                    const DropdownMenuItem(
                      value: 'owner',
                      child: Text('Chủ nhóm'),
                    ),
                  if (member.role != 'owner') ...[
                    const DropdownMenuItem(
                      value: 'admin',
                      child: Text('Quản trị viên'),
                    ),
                    const DropdownMenuItem(
                      value: 'member',
                      child: Text('Thành viên'),
                    ),
                  ],
                ],
                onChanged: member.role == 'owner'
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedRole = value;
                          });
                        }
                      },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final request = UpdateMemberRequest(
                    nickname: nicknameController.text.trim().isEmpty
                        ? null
                        : nicknameController.text.trim(),
                    role: selectedRole,
                  );

                  await ref
                      .read(groupMemberViewModelProvider(groupId).notifier)
                      .updateMember(member.userId, request);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật thành viên thành công!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveMemberDialog(
    BuildContext context,
    WidgetRef ref,
    GroupMember member,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${member.nickname != null && member.nickname!.isNotEmpty ? '${member.nickname} (${member.user.username})' : member.user.username}" khỏi nhóm?',
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
                    .read(groupMemberViewModelProvider(groupId).notifier)
                    .deleteMember(member.userId);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa thành viên thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thành viên'),
        content: const Text('Chức năng thêm thành viên đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
