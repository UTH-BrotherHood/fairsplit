import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';
import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';
import 'package:fairsplit/features/shopping/presentation/viewmodels/shopping_list_view_model.dart';
import 'package:fairsplit/features/shopping/presentation/pages/shopping_list_detail_page.dart';

class GroupDetailPage extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailPage({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends ConsumerState<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load shopping lists when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shoppingListsViewModelProvider.notifier)
          .getShoppingLists(widget.groupId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupViewModelProvider);
    final shoppingListsState = ref.watch(shoppingListsViewModelProvider);

    // Find the specific group from the loaded groups
    Group? currentGroup;
    groupsState.whenData((groupsResponse) {
      currentGroup = groupsResponse.items
          .where((g) => g.id == widget.groupId)
          .firstOrNull;
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          currentGroup?.name ?? 'Loading...',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showGroupMenu(context),
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group info section
          if (currentGroup != null) _buildGroupInfo(currentGroup!),

          // Tab bar for Bills and Shopping Lists
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt, size: 20),
                      const SizedBox(width: 8),
                      const Text('Hóa đơn'),
                      if (currentGroup != null &&
                          currentGroup!.bills.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${currentGroup!.bills.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart, size: 20),
                      const SizedBox(width: 8),
                      const Text('Mua sắm'),
                      if (currentGroup != null &&
                          currentGroup!.shoppingLists.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${currentGroup!.shoppingLists.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Bills tab
                if (currentGroup != null)
                  _buildBillsSection(currentGroup!)
                else
                  const Center(child: CircularProgressIndicator()),

                // Shopping lists tab
                _buildShoppingListsSection(shoppingListsState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListDialog(context),
        backgroundColor: const Color(0xFF87CEEB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGroupInfo(Group group) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.group, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.people, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${group.members.length} thành viên',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(width: 20),
              Icon(Icons.monetization_on, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                group.settings.currency,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillsSection(Group group) {
    final bills = group.bills;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: bills.isEmpty
          ? _buildEmptyBillsState()
          : RefreshIndicator(
              onRefresh: () async {
                // Refresh group data to get updated bills
                await ref.read(groupViewModelProvider.notifier).refreshGroups();
              },
              color: const Color(0xFF87CEEB),
              child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return _buildBillCard(bill);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyBillsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
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
            'Hãy tạo hóa đơn đầu tiên để chia sẻ chi phí',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddBillDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF87CEEB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tạo hóa đơn mới'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(GroupBill bill) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (bill.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Chờ thanh toán';
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openBillDetail(bill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF87CEEB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.receipt,
                      color: Color(0xFF87CEEB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                    Icons.monetization_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${bill.totalAmount.toStringAsFixed(0)} ${bill.currency}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF87CEEB),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(bill.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openBillDetail(GroupBill bill) {
    // TODO: Navigate to bill detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mở chi tiết hóa đơn: ${bill.name}'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
    );
  }

  void _showGroupMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Thành viên nhóm'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to group members page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt nhóm'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to group settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Lưu trữ nhóm'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Archive group functionality
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddListDialog(BuildContext context) {
    // TODO: Implement add shopping list dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng thêm danh sách đang được phát triển'),
        backgroundColor: Color(0xFF87CEEB),
      ),
    );
  }

  void _showAddBillDialog(BuildContext context) {
    // TODO: Show add bill dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng tạo hóa đơn sẽ được cập nhật sau'),
        backgroundColor: Color(0xFF87CEEB),
      ),
    );
  }

  Widget _buildShoppingListsSection(
    AsyncValue<List<ShoppingList>> shoppingListsState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: shoppingListsState.when(
              data: (shoppingLists) => shoppingLists.isEmpty
                  ? _buildEmptyShoppingListState()
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(shoppingListsViewModelProvider.notifier)
                          .refreshShoppingLists(),
                      color: const Color(0xFF87CEEB),
                      child: ListView.builder(
                        itemCount: shoppingLists.length,
                        itemBuilder: (context, index) {
                          final shoppingList = shoppingLists[index];
                          return _buildShoppingListCard(shoppingList);
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải danh sách',
                      style: TextStyle(fontSize: 16, color: Colors.red[600]),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref
                          .read(shoppingListsViewModelProvider.notifier)
                          .refreshShoppingLists(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShoppingListState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có danh sách mua sắm',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo danh sách đầu tiên để bắt đầu mua sắm cùng nhóm',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddListDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF87CEEB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tạo danh sách mới'),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListCard(ShoppingList shoppingList) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (shoppingList.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        statusIcon = Icons.check_circle;
        break;
      case 'active':
        statusColor = const Color(0xFF87CEEB);
        statusText = 'Đang hoạt động';
        statusIcon = Icons.shopping_cart;
        break;
      case 'archived':
        statusColor = Colors.grey;
        statusText = 'Lưu trữ';
        statusIcon = Icons.archive;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
        statusIcon = Icons.help_outline;
    }

    final completedItems = shoppingList.items
        .where((item) => item.isPurchased)
        .length;
    final totalItems = shoppingList.items.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openShoppingListDetail(shoppingList),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shoppingList.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shoppingList.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.checklist, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$completedItems/$totalItems items',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (shoppingList.dueDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(shoppingList.dueDate!),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              if (totalItems > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completedItems / totalItems,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openShoppingListDetail(ShoppingList shoppingList) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailPage(listId: shoppingList.id),
      ),
    );
    // Refresh both shopping lists and group data when coming back from detail page
    ref.read(shoppingListsViewModelProvider.notifier).refreshShoppingLists();
    ref.read(groupViewModelProvider.notifier).refreshGroups();
  }
}
