import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_member_view_model.dart';
import 'package:fairsplit/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fairsplit/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:fairsplit/features/expenses/data/datasources/category_remote_datasource.dart';
import 'package:fairsplit/injection.dart' as di;
import 'package:http/http.dart' as http;

class CreateBillPage extends ConsumerStatefulWidget {
  final String groupId;
  final String? billId; // For editing existing bill

  const CreateBillPage({super.key, required this.groupId, this.billId});

  @override
  ConsumerState<CreateBillPage> createState() => _CreateBillPageState();
}

class _CreateBillPageState extends ConsumerState<CreateBillPage> {
  // Thêm danh sách participant được chọn
  List<UserSearchResult> _selectedParticipants = [];
  final TextEditingController _participantSearchController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = '';
  String _selectedSplitMethod = 'equal';
  String _selectedCurrency = 'VND';
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'pending';

  List<Category> _categories = [];
  bool _isLoadingCategories = false;

  final List<String> _splitMethods = ['equal', 'percentage'];
  final List<String> _currencies = ['VND', 'USD'];
  final List<String> _statuses = ['pending', 'partially_paid', 'paid'];

  bool _isLoading = false;
  bool _isEditing = false;
  String? _currentUserId;

  // Hàm tìm kiếm user, đặt ngay sau biến khai báo

  // Hàm tìm kiếm user, phải đặt trước khi dùng trong build

  // Hàm tìm kiếm user, phải đặt trước khi dùng trong build

  @override
  void initState() {
    super.initState();
    _isEditing = widget.billId != null;
    _getCurrentUser();
    _loadCategories();
    if (_isEditing) {
      _loadBillData();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categoryDataSource = CategoryRemoteDataSourceImpl(
        client: http.Client(),
      );
      final response = await categoryDataSource.getCategories();
      setState(() {
        _categories = response.data.categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categories = [];
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải danh mục: $e')));
      }
    }
  }

  Future<void> _getCurrentUser() async {
    try {
      final profileDataSource = ProfileLocalDatasource();
      final user = profileDataSource.getUser();
      if (user != null) {
        _currentUserId = user.id;
        print('Current user ID from local: $_currentUserId');
      } else {
        print('No user found in local datasource');
        // Try to get from API using auth token
        await _getCurrentUserFromAPI();
      }
    } catch (e) {
      print('Error getting current user from local: $e');
      // Fallback to API
      await _getCurrentUserFromAPI();
    }
  }

  Future<void> _getCurrentUserFromAPI() async {
    try {
      final userDataSource = UserRemoteDataSourceImpl(client: http.Client());
      final response = await userDataSource.getCurrentUser();

      setState(() {
        _currentUserId = response.data.id;
      });

      print('Current user ID from API: $_currentUserId');
    } catch (e) {
      print('Error getting current user from API: $e');
      // Fallback to token existence check
      final authDataSource = AuthLocalDataSource();
      final token = await authDataSource.getAccessToken();

      if (token != null) {
        print('Found access token, user should be logged in');
        _currentUserId = 'current-user-placeholder';
      } else {
        print('No access token found');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBillData() async {
    if (widget.billId == null) return;

    setState(() => _isLoading = true);

    try {
      // Load bill data for editing
      // TODO: Implement getBillById in repository
      // final bill = await ref.read(billsViewModelProvider.notifier).getBillById(widget.billId!);
      // if (bill != null) {
      //   _titleController.text = bill.title;
      //   _descriptionController.text = bill.description;
      //   _amountController.text = bill.amount.toString();
      //   _selectedCategory = bill.category;
      //   _selectedSplitMethod = bill.splitMethod;
      //   _selectedCurrency = bill.currency;
      //   _selectedDate = bill.date;
      //   _selectedStatus = bill.status;
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu bill: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Chỉnh sửa Bill' : 'Tạo Bill mới',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildAmountSection(),
                    const SizedBox(height: 24),
                    _buildCategorySection(),
                    const SizedBox(height: 24),
                    _buildSplitMethodSection(),
                    const SizedBox(height: 24),
                    _buildDateSection(),
                    const SizedBox(height: 24),
                    if (_isEditing) _buildStatusSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin cơ bản',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Tiêu đề *',
            hintText: 'Nhập tiêu đề bill',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tiêu đề';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Mô tả',
            hintText: 'Nhập mô tả chi tiết',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số tiền',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Số tiền *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Tiền tệ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Chọn danh mục',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: _isLoadingCategories
              ? const Text('Đang tải danh mục...')
              : const Text('Chọn danh mục'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn danh mục';
            }
            return null;
          },
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
        const SizedBox(height: 24),
        _buildParticipantSection(),
      ],
    );
  }

  Widget _buildParticipantSection() {
    return Consumer(
      builder: (context, ref, _) {
        final userSearchState = ref.watch(userSearchViewModelProvider);
        void _onSearchUser() {
          final value = _participantSearchController.text.trim();
          if (value.isNotEmpty) {
            ref.read(userSearchViewModelProvider.notifier).searchUsers(value);
          } else {
            ref.read(userSearchViewModelProvider.notifier).clearSearch();
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thành viên tham gia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
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
                      controller: _participantSearchController,
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
                        _onSearchUser();
                      },
                      onChanged: (value) {
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
                      onPressed: _onSearchUser,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            userSearchState.when(
              data: (searchResponse) {
                if (searchResponse.users.isEmpty &&
                    _participantSearchController.text.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_off,
                          color: Colors.orange[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Không tìm thấy người dùng nào với email "${_participantSearchController.text}"',
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
                          Icon(
                            Icons.search,
                            color: Colors.green[600],
                            size: 16,
                          ),
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
                      final alreadySelected = _selectedParticipants.any(
                        (u) => u.id == user.id,
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
                            backgroundImage:
                                user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child:
                                (user.avatarUrl == null ||
                                    user.avatarUrl!.isEmpty)
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
                          trailing: alreadySelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF4A90E2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _selectedParticipants.add(user);
                                    });
                                  },
                                ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
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
            if (_selectedParticipants.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Đã chọn:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: _selectedParticipants
                    .map(
                      (user) => Chip(
                        label: Text(user.username),
                        avatar:
                            (user.avatarUrl != null &&
                                user.avatarUrl!.isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(user.avatarUrl!),
                              )
                            : CircleAvatar(
                                backgroundColor: const Color(0xFF4A90E2),
                                child: Text(
                                  user.username.isNotEmpty
                                      ? user.username[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                        onDeleted: () {
                          setState(() {
                            _selectedParticipants.removeWhere(
                              (u) => u.id == user.id,
                            );
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSplitMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức chia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedSplitMethod,
          decoration: InputDecoration(
            labelText: 'Chọn phương thức chia',
            prefixIcon: const Icon(Icons.pie_chart),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: _splitMethods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method == 'equal' ? 'Chia đều' : 'Theo phần trăm'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedSplitMethod = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày tạo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trạng thái',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: InputDecoration(
            labelText: 'Chọn trạng thái',
            prefixIcon: const Icon(Icons.info_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: _statuses.map((status) {
            String displayText;
            switch (status) {
              case 'pending':
                displayText = 'Chờ thanh toán';
                break;
              case 'partially_paid':
                displayText = 'Thanh toán một phần';
                break;
              case 'paid':
                displayText = 'Đã thanh toán';
                break;
              default:
                displayText = status;
            }
            return DropdownMenuItem(value: status, child: Text(displayText));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedStatus = value);
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveBill,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isEditing ? 'Cập nhật Bill' : 'Tạo Bill',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate current user
    if (_currentUserId == null ||
        _currentUserId == 'current-user-placeholder') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể xác định người dùng hiện tại. Vui lòng thử lại.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate category selection
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      print('Creating bill with data:');
      print('GroupId: ${widget.groupId}');
      print('Title: ${_titleController.text.trim()}');
      print('Amount: $amount');
      print('CurrentUserId: $_currentUserId');
      print('Category: $_selectedCategory');

      if (_isEditing) {
        // Update existing bill using BillDetailViewModel
        final updateRequest = CreateBillRequest(
          groupId: widget.groupId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          category: _selectedCategory,
          splitMethod: _selectedSplitMethod,
          paidBy: _currentUserId!,
          participants: [
            CreateBillParticipant(userId: _currentUserId!, share: 100.0),
          ],
          status: _selectedStatus,
          payments: [],
        );

        // Use BillDetailViewModel to update bill
        await ref
            .read(di.billDetailViewModelProvider.notifier)
            .updateBill(widget.billId!, updateRequest);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bill đã được cập nhật thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create new bill
        final request = CreateBillRequest(
          groupId: widget.groupId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          category: _selectedCategory,
          splitMethod: _selectedSplitMethod,
          paidBy: _currentUserId!,
          participants: [
            CreateBillParticipant(userId: _currentUserId!, share: 100.0),
          ],
          status: 'pending',
          payments: [],
        );

        print('Create request: ${request.toJson()}');

        // Use BillsViewModel to create bill
        await ref.read(di.billsViewModelProvider.notifier).createBill(request);

        print('Bill created successfully!');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bill đã được tạo thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error creating bill: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bill này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteBill();
    }
  }

  Future<void> _deleteBill() async {
    if (widget.billId == null) return;

    setState(() => _isLoading = true);

    try {
      // Use BillDetailViewModel to delete bill
      await ref
          .read(di.billDetailViewModelProvider.notifier)
          .deleteBill(widget.billId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill đã được xóa thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa bill: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
