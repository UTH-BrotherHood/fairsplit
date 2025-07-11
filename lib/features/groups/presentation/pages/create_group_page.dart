import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_member_view_model.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  List<UserSearchResult> _selectedMembers = [];
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userSearchState = ref.watch(userSearchViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tạo nhóm mới'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createGroup,
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4A90E2),
                    ),
                  )
                : const Text(
                    'Tạo',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Info Section
              _buildGroupInfoSection(),

              const SizedBox(height: 24),

              // Members Section
              _buildMembersSection(userSearchState),

              const SizedBox(height: 24),

              // Settings Section
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin nhóm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Tên nhóm',
          icon: Icons.group,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên nhóm';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Mô tả nhóm',
          icon: Icons.description,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mô tả nhóm';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMembersSection(AsyncValue<UserSearchResponse> userSearchState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Thành viên',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedMembers.length} người',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nhập email người dùng trong ô tìm kiếm bên dưới, sau đó nhấn Enter hoặc nút tìm kiếm để tìm và chọn thành viên',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Search box
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText:
                        'Nhập email người dùng và nhấn Enter hoặc nút tìm kiếm...',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref
                          .read(userSearchViewModelProvider.notifier)
                          .searchUsers(value.trim());
                    }
                  },
                  onChanged: (value) {
                    // Clear search results when input is empty
                    if (value.isEmpty) {
                      ref
                          .read(userSearchViewModelProvider.notifier)
                          .clearSearch();
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF4A90E2)),
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      ref
                          .read(userSearchViewModelProvider.notifier)
                          .searchUsers(query);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập email để tìm kiếm'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Search results
        userSearchState.when(
          data: (searchResponse) => _buildSearchResults(searchResponse),
          loading: () => Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Đang tìm kiếm người dùng...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lỗi tìm kiếm: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Selected members
        if (_selectedMembers.isNotEmpty) _buildSelectedMembers(),
      ],
    );
  }

  Widget _buildSearchResults(UserSearchResponse searchResponse) {
    if (searchResponse.users.isEmpty && _searchController.text.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search_off, color: Colors.orange[600], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Không tìm thấy người dùng nào với email "${_searchController.text}"',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      );
    }

    if (searchResponse.users.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.green[600], size: 16),
              const SizedBox(width: 4),
              Text(
                'Tìm thấy ${searchResponse.users.length} người dùng:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ...searchResponse.users.map((user) {
          final isSelected = _selectedMembers.any(
            (member) => member.id == user.id,
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF4A90E2),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.username.isNotEmpty
                            ? user.username[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              title: Text(user.username),
              subtitle: Text(user.email),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF4A90E2))
                  : IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addMember(user),
                    ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSelectedMembers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thành viên đã chọn:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedMembers.map((member) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFF4A90E2),
                    backgroundImage: member.avatarUrl != null
                        ? NetworkImage(member.avatarUrl!)
                        : null,
                    child: member.avatarUrl == null
                        ? Text(
                            member.username.isNotEmpty
                                ? member.username[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.username,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeMember(member),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt nhóm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                'Cho phép thành viên mời người khác',
                'Thành viên có thể mời người khác vào nhóm',
                true,
              ),
              const Divider(),
              _buildSettingItem(
                'Cho phép thành viên tạo danh sách',
                'Thành viên có thể tạo danh sách mua sắm',
                true,
              ),
              const Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phương thức chia',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Cách chia tiền mặc định',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Chia đều',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, String subtitle, bool value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (value) {
            // Handle setting change
          },
          activeColor: const Color(0xFF4A90E2),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _addMember(UserSearchResult user) {
    setState(() {
      if (!_selectedMembers.any((member) => member.id == user.id)) {
        _selectedMembers.add(user);
      }
    });
  }

  void _removeMember(UserSearchResult user) {
    setState(() {
      _selectedMembers.removeWhere((member) => member.id == user.id);
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final members = _selectedMembers
          .map((user) => GroupMemberInput(userId: user.id, role: 'member'))
          .toList();

      final request = CreateGroupRequest(
        name: _nameController.text,
        description: _descriptionController.text,
        members: members,
        settings: GroupSettingsInput(
          allowMembersInvite: true,
          allowMembersAddList: true,
          defaultSplitMethod: 'equal',
          currency: 'VND',
        ),
      );

      await ref.read(groupViewModelProvider.notifier).createGroup(request);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tạo nhóm thành công!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tạo nhóm: $e')));
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
}
