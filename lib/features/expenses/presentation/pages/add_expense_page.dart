import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/injection.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  final Group group;

  const AddExpensePage({super.key, required this.group});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'Ăn uống';
  String _selectedSplitMethod = 'equal';
  final List<String> _categories = [
    'Ăn uống',
    'Di chuyển',
    'Giải trí',
    'Mua sắm',
    'Y tế',
    'Khác',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billsState = ref.watch(billsViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thêm chi tiêu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tạo khoản chi tiêu mới',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Tiêu đề',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Mô tả (tùy chọn)',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _amountController,
                        label: 'Số tiền',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số tiền';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Vui lòng nhập số tiền hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Danh mục',
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Phương thức chia',
                        value: _selectedSplitMethod,
                        items: const ['equal', 'percentage'],
                        displayItems: const ['Chia đều', 'Theo phần trăm'],
                        onChanged: (value) {
                          setState(() {
                            _selectedSplitMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: billsState.isLoading ? null : _createBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87CEEB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: billsState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Tạo chi tiêu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF87CEEB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    List<String>? displayItems,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF87CEEB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: items.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            String displayText = displayItems != null
                ? displayItems[index]
                : item;

            return DropdownMenuItem<String>(
              value: item,
              child: Text(displayText),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _createBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);

    // Create participants list from group members
    final participants = widget.group.members.map((member) {
      return CreateBillParticipant(userId: member.userId);
    }).toList();

    final request = CreateBillRequest(
      groupId: widget.group.id,
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? 'Không có mô tả'
          : _descriptionController.text,
      amount: amount,
      currency: 'VND',
      date: DateTime.now(),
      category: _selectedCategory,
      splitMethod: _selectedSplitMethod,
      paidBy: widget.group.members.isNotEmpty
          ? widget.group.members.first.userId
          : '',
      participants: participants,
    );

    try {
      await ref.read(billsViewModelProvider.notifier).createBill(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo chi tiêu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo chi tiêu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
