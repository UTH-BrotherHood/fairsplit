import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';

class EditGroupPage extends ConsumerStatefulWidget {
  final Group group;

  const EditGroupPage({super.key, required this.group});

  @override
  ConsumerState<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends ConsumerState<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isUpdating = false;
  String _selectedCurrency = 'VND';
  bool _allowMembersInvite = true;
  bool _allowMembersAddList = true;
  String _defaultSplitMethod = 'equal';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(
      text: widget.group.description,
    );
    _selectedCurrency = widget.group.settings.currency;
    _allowMembersInvite = widget.group.settings.allowMembersInvite;
    _allowMembersAddList = widget.group.settings.allowMembersAddList;
    _defaultSplitMethod = widget.group.settings.defaultSplitMethod;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chỉnh sửa nhóm'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : _updateGroup,
            child: _isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4A90E2),
                    ),
                  )
                : const Text(
                    'Lưu',
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

              // Settings Section
              _buildSettingsSection(),

              const SizedBox(height: 24),

              // Danger Zone
              _buildDangerZone(),
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

        // Name field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Tên nhóm',
            hintText: 'Nhập tên nhóm...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên nhóm';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Description field
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Mô tả',
            hintText: 'Nhập mô tả nhóm...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mô tả nhóm';
            }
            return null;
          },
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

        // Currency selection
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 12),
                  const Text(
                    'Tiền tệ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    items: ['VND', 'USD', 'EUR']
                        .map(
                          (currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Split method
              Row(
                children: [
                  const Icon(Icons.call_split, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 12),
                  const Text(
                    'Phương thức chia tiền mặc định',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _defaultSplitMethod,
                    items: [
                      const DropdownMenuItem(
                        value: 'equal',
                        child: Text('Chia đều'),
                      ),
                      const DropdownMenuItem(
                        value: 'percentage',
                        child: Text('Theo tỷ lệ'),
                      ),
                      const DropdownMenuItem(
                        value: 'exact',
                        child: Text('Chính xác'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _defaultSplitMethod = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Permissions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Cho phép thành viên mời người khác'),
                subtitle: const Text(
                  'Thành viên có thể thêm người mới vào nhóm',
                ),
                value: _allowMembersInvite,
                onChanged: (value) {
                  setState(() {
                    _allowMembersInvite = value;
                  });
                },
                activeColor: const Color(0xFF4A90E2),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Cho phép thành viên tạo danh sách'),
                subtitle: const Text('Thành viên có thể tạo danh sách mua sắm'),
                value: _allowMembersAddList,
                onChanged: (value) {
                  setState(() {
                    _allowMembersAddList = value;
                  });
                },
                activeColor: const Color(0xFF4A90E2),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vùng nguy hiểm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            children: [
              if (!widget.group.isArchived)
                ListTile(
                  leading: const Icon(Icons.archive, color: Colors.orange),
                  title: const Text('Lưu trữ nhóm'),
                  subtitle: const Text('Nhóm sẽ được ẩn khỏi danh sách chính'),
                  trailing: ElevatedButton(
                    onPressed: () => _archiveGroup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lưu trữ'),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              if (!widget.group.isArchived) const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Xóa nhóm'),
                subtitle: const Text('Xóa vĩnh viễn nhóm và tất cả dữ liệu'),
                trailing: ElevatedButton(
                  onPressed: () => _deleteGroup(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xóa'),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final request = UpdateGroupRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        settings: GroupSettingsInput(
          allowMembersInvite: _allowMembersInvite,
          allowMembersAddList: _allowMembersAddList,
          defaultSplitMethod: _defaultSplitMethod,
          currency: _selectedCurrency,
        ),
      );

      await ref
          .read(groupViewModelProvider.notifier)
          .updateGroup(widget.group.id, request);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật nhóm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _archiveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu trữ nhóm'),
        content: Text(
          'Bạn có chắc chắn muốn lưu trữ nhóm "${widget.group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Lưu trữ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement archive API call
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chức năng đang phát triển')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhóm'),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhóm "${widget.group.name}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(groupViewModelProvider.notifier)
            .deleteGroup(widget.group.id);

        if (mounted) {
          // Pop back to groups list
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Add a small delay to ensure UI updates
          await Future.delayed(const Duration(milliseconds: 200));
          // Force refresh
          ref.read(groupViewModelProvider.notifier).refreshGroups();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa nhóm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
