import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/injection.dart' as di;
import 'package:fairsplit/features/groups/domain/entities/group.dart';

class BillFormDialog extends ConsumerStatefulWidget {
  final Bill? bill; // null for create, non-null for edit
  final String groupId;
  final List<GroupMember> groupMembers;

  const BillFormDialog({
    Key? key,
    this.bill,
    required this.groupId,
    required this.groupMembers,
  }) : super(key: key);

  @override
  ConsumerState<BillFormDialog> createState() => _BillFormDialogState();
}

class _BillFormDialogState extends ConsumerState<BillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCurrency = 'VND';
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Ăn uống';
  String _selectedSplitMethod = 'equal';
  String? _selectedPaidBy;
  String _selectedStatus = 'pending';

  List<String> _selectedParticipants = [];

  final List<String> _currencies = ['VND', 'USD'];
  final List<String> _categories = [
    'Ăn uống',
    'Đi lại',
    'Mua sắm',
    'Giải trí',
    'Khác',
  ];
  final List<String> _splitMethods = ['equal', 'percentage'];
  final List<String> _statuses = ['pending', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();

    if (widget.bill != null) {
      // Edit mode - populate fields
      _titleController.text = widget.bill!.title;
      _descriptionController.text = widget.bill!.description;
      _amountController.text = widget.bill!.amount.toString();
      _selectedCurrency = widget.bill!.currency;
      _selectedDate = widget.bill!.date;
      _selectedCategory = widget.bill!.category;
      _selectedSplitMethod = widget.bill!.splitMethod;
      _selectedPaidBy = widget.bill!.paidBy;
      _selectedStatus = widget.bill!.status;
      _selectedParticipants = widget.bill!.participants
          .map((p) => p.userId)
          .toList();
    } else {
      // Create mode - set defaults
      if (widget.groupMembers.isNotEmpty) {
        _selectedPaidBy = widget.groupMembers.first.userId;
        _selectedParticipants = [widget.groupMembers.first.userId];
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bill != null;

    return AlertDialog(
      title: Text(isEdit ? 'Sửa hóa đơn' : 'Tạo hóa đơn mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Amount and Currency
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Tiền tệ',
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Split Method
              DropdownButtonFormField<String>(
                value: _selectedSplitMethod,
                decoration: const InputDecoration(
                  labelText: 'Phương thức chia',
                  border: OutlineInputBorder(),
                ),
                items: _splitMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(
                      method == 'equal' ? 'Chia đều' : 'Chia theo tỷ lệ',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSplitMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Paid By
              DropdownButtonFormField<String>(
                value: _selectedPaidBy,
                decoration: const InputDecoration(
                  labelText: 'Người thanh toán',
                  border: OutlineInputBorder(),
                ),
                items: widget.groupMembers.map((member) {
                  return DropdownMenuItem(
                    value: member.userId,
                    child: Text(member.user.username),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaidBy = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn người thanh toán';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
                  String displayName = status;
                  switch (status) {
                    case 'pending':
                      displayName = 'Chờ xử lý';
                      break;
                    case 'completed':
                      displayName = 'Hoàn thành';
                      break;
                    case 'cancelled':
                      displayName = 'Đã hủy';
                      break;
                  }
                  return DropdownMenuItem(
                    value: status,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Participants
              const Text(
                'Người tham gia:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.groupMembers.map((member) {
                return CheckboxListTile(
                  title: Text(member.user.username),
                  value: _selectedParticipants.contains(member.userId),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedParticipants.add(member.userId);
                      } else {
                        _selectedParticipants.remove(member.userId);
                      }
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_selectedParticipants.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng chọn ít nhất một người tham gia'),
                  ),
                );
                return;
              }

              final request = CreateBillRequest(
                groupId: widget.groupId,
                title: _titleController.text,
                description: _descriptionController.text.isEmpty
                    ? ''
                    : _descriptionController.text,
                amount: double.parse(_amountController.text),
                currency: _selectedCurrency,
                date: _selectedDate,
                category: _selectedCategory,
                splitMethod: _selectedSplitMethod,
                paidBy: _selectedPaidBy!,
                participants: _selectedParticipants
                    .map((userId) => CreateBillParticipant(userId: userId))
                    .toList(),
                status: _selectedStatus,
                payments: [],
              );

              if (isEdit) {
                ref
                    .read(di.billDetailViewModelProvider.notifier)
                    .updateBill(widget.bill!.id, request);
              } else {
                // For create bill, we need to handle it differently
                // This would typically be handled by a bills list provider
              }

              Navigator.of(context).pop();
            }
          },
          child: Text(isEdit ? 'Cập nhật' : 'Tạo'),
        ),
      ],
    );
  }
}
