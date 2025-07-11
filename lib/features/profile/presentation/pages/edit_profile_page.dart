import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fairsplit/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:fairsplit/features/profile/data/models/update_profile_request.dart';
import 'package:fairsplit/features/auth/domain/entities/auth.dart';
import 'package:fairsplit/shared/widgets/custom_text_field.dart';
import 'package:fairsplit/core/utils/snarbar.dart';
import 'package:fairsplit/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'dart:io';

class EditProfilePage extends ConsumerStatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  DateTime? _selectedDateOfBirth;
  String? _selectedProfileVisibility;
  String? _selectedFriendRequests;
  bool _isLoading = false;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initFields(widget.user);
  }

  void _initFields(User user) {
    _usernameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email ?? '');
    _phoneController = TextEditingController(text: user.phone ?? '');
    _selectedDateOfBirth = user.dateOfBirth;
    _selectedProfileVisibility = user.privacySettings?.profileVisibility;
    _selectedFriendRequests = user.privacySettings?.friendRequests;
    _selectedImageFile = null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      showSnackBar(
        content: 'Failed to pick image: ${e.toString()}',
        context: context,
        backgroundColor: Colors.red,
      );
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = UpdateProfileRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        dateOfBirth: _selectedDateOfBirth,
        avatarFile: _selectedImageFile,
        privacySettings: PrivacySettingsRequest(
          profileVisibility: _selectedProfileVisibility,
          friendRequests: _selectedFriendRequests,
        ),
      );

      await ref.read(profileViewModelProvider.notifier).updateProfile(request);
      // Lấy dữ liệu mới nhất từ server và cập nhật lại form
      final userAsync = ref.read(profileViewModelProvider);
      if (userAsync is AsyncData<User>) {
        final newUser = userAsync.value;
        setState(() {
          _initFields(newUser);
        });
      }
      showSnackBar(
        content: 'Profile updated successfully!',
        context: context,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      showSnackBar(
        content: 'Failed to update profile: ${e.toString()}',
        context: context,
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFF9FAFB),
                            backgroundImage: _selectedImageFile != null
                                ? FileImage(_selectedImageFile!)
                                : (widget.user.avatarUrl != null &&
                                              widget.user.avatarUrl!.isNotEmpty
                                          ? NetworkImage(widget.user.avatarUrl!)
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_selectedImageFile == null &&
                                    (widget.user.avatarUrl == null ||
                                        widget.user.avatarUrl!.isEmpty))
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _showImagePickerDialog,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Change Photo'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Basic Information Section
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _usernameController,
                hintText: 'Username',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                hintText: 'Email (Optional)',
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                hintText: 'Phone (Optional)',
                prefixIcon: Icons.phone_outlined,
              ),

              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Birth',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDateOfBirth != null
                                  ? '${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}/'
                                        '${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}/'
                                        '${_selectedDateOfBirth!.year}'
                                  : 'Not set',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Privacy Settings Section
              _buildSectionTitle('Privacy Settings'),
              const SizedBox(height: 16),

              // Profile Visibility
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Profile Visibility',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedProfileVisibility,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'public',
                          child: Text('Public'),
                        ),
                        DropdownMenuItem(
                          value: 'friends',
                          child: Text('Friends Only'),
                        ),
                        DropdownMenuItem(
                          value: 'private',
                          child: Text('Private'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedProfileVisibility = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Friend Requests
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.grey[600]),
                        const SizedBox(width: 16),
                        const Text(
                          'Friend Requests',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedFriendRequests,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'everyone',
                          child: Text('Everyone'),
                        ),
                        DropdownMenuItem(
                          value: 'friendsOfFriends',
                          child: Text('Friends of Friends'),
                        ),
                        DropdownMenuItem(value: 'none', child: Text('None')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFriendRequests = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}
