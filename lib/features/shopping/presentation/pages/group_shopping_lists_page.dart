import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';
import 'package:fairsplit/features/shopping/presentation/viewmodels/shopping_list_view_model.dart';
import 'package:fairsplit/features/shopping/presentation/pages/shopping_list_detail_page.dart';
import 'package:fairsplit/features/shopping/presentation/pages/create_shopping_list_page.dart';

class GroupShoppingListsPage extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupShoppingListsPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupShoppingListsPage> createState() =>
      _GroupShoppingListsPageState();
}

class _GroupShoppingListsPageState
    extends ConsumerState<GroupShoppingListsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shoppingListsViewModelProvider.notifier)
          .getShoppingLists(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListsState = ref.watch(shoppingListsViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Shopping Lists - ${widget.groupName}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showCreateShoppingListDialog();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: shoppingListsState.when(
        data: (shoppingLists) => _buildShoppingListsView(shoppingLists),
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildShoppingListsView(List<ShoppingList> shoppingLists) {
    if (shoppingLists.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(shoppingListsViewModelProvider.notifier)
            .refreshShoppingLists();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shoppingLists.length,
        itemBuilder: (context, index) {
          final shoppingList = shoppingLists[index];
          return _buildShoppingListCard(shoppingList);
        },
      ),
    );
  }

  Widget _buildShoppingListCard(ShoppingList shoppingList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getStatusColor(shoppingList.status),
          child: Icon(
            _getStatusIcon(shoppingList.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          shoppingList.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (shoppingList.description.isNotEmpty)
              Text(
                shoppingList.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${shoppingList.items.length} món',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.monetization_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${shoppingList.totalEstimatedPrice.toStringAsFixed(0)} VND',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (shoppingList.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Hạn: ${_formatDate(shoppingList.dueDate!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(shoppingList.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(shoppingList.status),
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(shoppingList.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShoppingListDetailPage(listId: shoppingList.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có shopping list nào',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo shopping list đầu tiên để bắt đầu',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateShoppingListDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo Shopping List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
    );
  }

  Widget _buildErrorState(Object error) {
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
                  .read(shoppingListsViewModelProvider.notifier)
                  .refreshShoppingLists();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF50C878);
      case 'in_progress':
        return const Color(0xFF4A90E2);
      case 'archived':
        return Colors.grey;
      default:
        return const Color(0xFFFFA500);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.access_time;
      case 'archived':
        return Icons.archive;
      default:
        return Icons.shopping_cart;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'in_progress':
        return 'Đang mua';
      case 'archived':
        return 'Lưu trữ';
      default:
        return 'Chờ xử lý';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateShoppingListDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateShoppingListPage(groupId: widget.groupId),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the shopping lists if creation was successful
        ref
            .read(shoppingListsViewModelProvider.notifier)
            .refreshShoppingLists();
      }
    });
  }
}
