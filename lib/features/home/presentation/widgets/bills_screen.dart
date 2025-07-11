import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/presentation/pages/bill_detail_page.dart';
import 'package:fairsplit/features/expenses/presentation/pages/all_bills_page.dart';
import 'package:fairsplit/injection.dart';

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGroupId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load groups on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupViewModelProvider.notifier).getMyGroups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Tab bar
            _buildTabBar(),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBillsTab(), _buildPaymentsTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBillDialog(),
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF4A90E2),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Bills',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllBillsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.list_rounded, size: 18),
                label: const Text('Tất cả'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showGroupSelector(),
                icon: const Icon(Icons.filter_list_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedGroupId.isNotEmpty
                ? 'Managing bills for ${_getSelectedGroupName()}'
                : 'Select a group to manage bills',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF4A90E2),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Bills'),
          Tab(text: 'Payments'),
        ],
      ),
    );
  }

  Widget _buildBillsTab() {
    if (_selectedGroupId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No group selected',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a group to view bills',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showGroupSelector(),
              icon: const Icon(Icons.group_rounded),
              label: const Text('Select Group'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final billsState = ref.watch(billsViewModelProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(billsViewModelProvider.notifier)
            .getBills(_selectedGroupId);
      },
      child: billsState.when(
        data: (bills) => _buildBillsList(bills),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error.toString()),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    if (_selectedGroupId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No group selected',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a group to view payments',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    final billsState = ref.watch(billsViewModelProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(billsViewModelProvider.notifier)
            .getBills(_selectedGroupId);
      },
      child: billsState.when(
        data: (bills) => _buildPaymentsList(bills),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error.toString()),
      ),
    );
  }

  Widget _buildPaymentsList(List<Bill> bills) {
    // Filter bills that have payments
    final billsWithPayments = bills
        .where((bill) => bill.payments.isNotEmpty)
        .toList();

    if (billsWithPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No payments yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payments will appear here once bills are created and paid',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: billsWithPayments.length,
      itemBuilder: (context, index) {
        final bill = billsWithPayments[index];
        return _buildPaymentCard(bill);
      },
    );
  }

  Widget _buildPaymentCard(Bill bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment_rounded,
                    color: Colors.green,
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bill.payments.length} payment(s)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${bill.amount.toStringAsFixed(0)} VND',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...bill.payments
                .map(
                  (payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Payment: ${payment.amount.toStringAsFixed(0)} VND',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(payment.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsList(List<Bill> bills) {
    if (bills.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return _buildBillCard(bill);
      },
    );
  }

  Widget _buildBillCard(Bill bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(bill.status).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToBillDetail(bill),
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
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bill.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${bill.amount.toStringAsFixed(0)} ${bill.currency}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              bill.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(bill.status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(bill.status),
                            ),
                          ),
                        ),
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
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(bill.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.group_rounded,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${bill.participants.length} people',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bills yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first bill to get started',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateBillDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Bill'),
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

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading bills',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (_selectedGroupId.isNotEmpty) {
                ref
                    .read(billsViewModelProvider.notifier)
                    .getBills(_selectedGroupId);
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partially_paid':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Đã thanh toán';
      case 'partially_paid':
        return 'Thanh toán một phần';
      case 'pending':
      default:
        return 'Chờ thanh toán';
    }
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

  String _getSelectedGroupName() {
    final groupsState = ref.read(groupViewModelProvider);
    return groupsState.when(
      data: (groupsResponse) {
        try {
          final group = groupsResponse.items.firstWhere(
            (group) => group.id == _selectedGroupId,
          );
          return group.name;
        } catch (e) {
          return 'Unknown Group';
        }
      },
      loading: () => 'Loading...',
      error: (error, stack) => 'Error',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToBillDetail(Bill bill) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BillDetailPage(billId: bill.id)),
    );
  }

  void _showCreateBillDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedCategory = 'Ăn uống';
    String selectedSplitMethod = 'equal';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Bill'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter bill title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter bill description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    prefixIcon: Icon(Icons.money),
                    suffixText: 'VND',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Ăn uống', child: Text('Ăn uống')),
                    DropdownMenuItem(value: 'Đi lại', child: Text('Đi lại')),
                    DropdownMenuItem(value: 'Mua sắm', child: Text('Mua sắm')),
                    DropdownMenuItem(
                      value: 'Giải trí',
                      child: Text('Giải trí'),
                    ),
                    DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategory = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSplitMethod,
                  decoration: const InputDecoration(
                    labelText: 'Split Method',
                    prefixIcon: Icon(Icons.pie_chart),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'equal',
                      child: Text('Equal Split'),
                    ),
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Percentage'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedSplitMethod = value;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (_selectedGroupId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a group first'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Create the bill request
                final request = CreateBillRequest(
                  groupId: _selectedGroupId,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  amount: double.parse(amountController.text),
                  currency: 'VND',
                  date: DateTime.now(),
                  category: selectedCategory,
                  splitMethod: selectedSplitMethod,
                  paidBy: 'current-user-id', // TODO: Get actual current user ID
                  participants: [
                    CreateBillParticipant(
                      userId: 'current-user-id',
                    ), // TODO: Get actual participants
                  ],
                );

                Navigator.pop(context);

                try {
                  await ref
                      .read(billsViewModelProvider.notifier)
                      .createBill(request);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bill created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating bill: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showGroupSelector() {
    final groupsState = ref.watch(groupViewModelProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Group'),
        content: SizedBox(
          width: double.maxFinite,
          child: groupsState.when(
            data: (groupsResponse) {
              if (groupsResponse.items.isEmpty) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('No groups available'),
                    SizedBox(height: 8),
                    Text(
                      'Create a group first to manage bills',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose a group to view bills:'),
                  const SizedBox(height: 16),
                  ...groupsResponse.items
                      .map(
                        (group) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(
                              0xFF4A90E2,
                            ).withOpacity(0.1),
                            child: const Icon(
                              Icons.group_rounded,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          title: Text(group.name),
                          subtitle: Text('${group.members.length} members'),
                          trailing: Radio<String>(
                            value: group.id,
                            groupValue: _selectedGroupId,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedGroupId = value;
                                });
                                Navigator.pop(context);
                                // Load bills for selected group
                                ref
                                    .read(billsViewModelProvider.notifier)
                                    .getBills(value);
                              }
                            },
                          ),
                        ),
                      )
                      .toList(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Error loading groups'),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (groupsState.hasError)
            TextButton(
              onPressed: () {
                ref.read(groupViewModelProvider.notifier).refreshGroups();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
