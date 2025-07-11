import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/presentation/pages/bill_detail_page.dart';
import 'package:fairsplit/features/expenses/presentation/pages/create_bill_page.dart';
import 'package:fairsplit/injection.dart' as di;

class AllBillsPage extends ConsumerStatefulWidget {
  final String? initialGroupId;
  final String? initialGroupName;
  final bool showCreateForm;

  const AllBillsPage({
    super.key,
    this.initialGroupId,
    this.initialGroupName,
    this.showCreateForm = false,
  });

  @override
  ConsumerState<AllBillsPage> createState() => _AllBillsPageState();
}

class _AllBillsPageState extends ConsumerState<AllBillsPage>
    with WidgetsBindingObserver {
  Map<String, List<Bill>> groupBills = {};
  bool isLoading = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllBills();
      // Show create form automatically if requested
      if (widget.showCreateForm && widget.initialGroupId != null) {
        _showCreateBillDialog(widget.initialGroupId!);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // Clear the state to prevent potential memory leaks
    groupBills.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isDisposed && mounted) {
      // Refresh data when app comes back to foreground
      _loadAllBills();
    }
  }

  Future<void> _loadAllBills() async {
    if (_isDisposed || !mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Get all groups first
      await ref.read(di.groupViewModelProvider.notifier).getMyGroups();

      if (_isDisposed || !mounted) return;

      final groupsState = ref.read(di.groupViewModelProvider);

      if (groupsState.hasValue) {
        final groups = groupsState.value!.items;
        Map<String, List<Bill>> allBills = {};

        // Extract bills directly from groups data
        for (final group in groups) {
          if (_isDisposed || !mounted) return;

          // Check if group has bills
          if (group.bills.isNotEmpty) {
            List<Bill> billsList = [];

            // Convert GroupBill to Bill entities
            for (final groupBill in group.bills) {
              try {
                final bill = Bill(
                  id: groupBill.id,
                  groupId: groupBill.groupId,
                  title: groupBill.title,
                  description: groupBill.description,
                  amount: groupBill.amount,
                  currency: groupBill.currency,
                  date: groupBill.date,
                  category: groupBill.category,
                  splitMethod: groupBill.splitMethod,
                  paidBy: groupBill.paidBy,
                  participants: groupBill.participants,
                  status: groupBill.status,
                  payments: groupBill.payments,
                  createdBy: groupBill.createdBy,
                  createdAt: groupBill.createdAt,
                  updatedAt: groupBill.updatedAt,
                );
                billsList.add(bill);
              } catch (e) {
                print('Error converting GroupBill to Bill: $e');
                continue;
              }
            }

            if (billsList.isNotEmpty) {
              allBills[group.name] = billsList;
              print(
                'Loaded ${billsList.length} bills for group: ${group.name}',
              );
            }
          }
        }

        if (!_isDisposed && mounted) {
          setState(() {
            groupBills = allBills;
          });
        }
      }
    } catch (e) {
      print('Error loading bills: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách hóa đơn: $e')),
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          isLoading = false;
        });
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
        title: const Text(
          'Tất cả Bills',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () {
              if (!_isDisposed && mounted) {
                _loadAllBills();
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllBills,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : groupBills.isEmpty
            ? _buildEmptyState()
            : _buildBillsView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_isDisposed && mounted) {
            _showCreateBillDialog();
          }
        },
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có hóa đơn nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo hóa đơn đầu tiên để bắt đầu',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (!_isDisposed && mounted) {
                _showCreateBillDialog();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo Hóa Đơn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsView() {
    return RefreshIndicator(
      onRefresh: _loadAllBills,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...groupBills.entries.map((entry) {
            final groupName = entry.key;
            final bills = entry.value;

            if (bills.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.group, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${bills.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...bills.map((bill) => _buildBillCard(bill)),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBillCard(Bill bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillDetailPage(billId: bill.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          bill.category,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(bill.category),
                        color: _getCategoryColor(bill.category),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (bill.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              bill.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatCurrency(bill.amount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateBillPage(
                                        groupId: bill.groupId,
                                        billId: bill.id,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result == true &&
                                        !_isDisposed &&
                                        mounted) {
                                      _loadAllBills();
                                    }
                                  });
                                } else if (value == 'delete') {
                                  _showDeleteBillDialog(bill);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Chỉnh sửa'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Xóa',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              child: const Icon(Icons.more_vert, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildStatusChip(bill.status),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(bill.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.group_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${bill.participants.length} người',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.pie_chart_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bill.splitMethod == 'equal' ? 'Chia đều' : 'Theo tỷ lệ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'paid':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        displayText = 'Đã thanh toán';
        break;
      case 'partially_paid':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        displayText = 'Thanh toán một phần';
        break;
      case 'pending':
      default:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        displayText = 'Chờ thanh toán';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return Colors.orange;
      case 'Đi lại':
        return Colors.blue;
      case 'Mua sắm':
        return Colors.purple;
      case 'Giải trí':
        return Colors.green;
      case 'Khác':
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant_rounded;
      case 'Đi lại':
        return Icons.directions_car_rounded;
      case 'Mua sắm':
        return Icons.shopping_bag_rounded;
      case 'Giải trí':
        return Icons.sports_esports_rounded;
      case 'Khác':
      default:
        return Icons.category_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VND';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K VND';
    } else {
      return '${amount.toStringAsFixed(0)} VND';
    }
  }

  void _showCreateBillDialog([String? selectedGroupId]) {
    // If a specific group is provided, navigate directly to create page
    if (selectedGroupId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateBillPage(groupId: selectedGroupId),
        ),
      ).then((result) {
        if (result == true && !_isDisposed && mounted) {
          _loadAllBills();
        }
      });
      return;
    }

    final groupsState = ref.read(di.groupViewModelProvider);

    if (!groupsState.hasValue || groupsState.value!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần có ít nhất một nhóm để tạo hóa đơn')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn nhóm'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groupsState.value!.items.length,
              itemBuilder: (context, index) {
                final group = groupsState.value!.items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                    child: Text(
                      group.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(group.name),
                  subtitle: Text('${group.members.length} thành viên'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateBillPage(groupId: group.id),
                      ),
                    ).then((result) {
                      if (result == true && !_isDisposed && mounted) {
                        _loadAllBills();
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteBillDialog(Bill bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bill "${bill.title}" không?'),
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
      try {
        // Use BillDetailViewModel to delete bill
        await ref
            .read(di.billDetailViewModelProvider.notifier)
            .deleteBill(bill.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bill đã được xóa thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAllBills(); // Refresh the list after deletion
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
      }
    }
  }
}
