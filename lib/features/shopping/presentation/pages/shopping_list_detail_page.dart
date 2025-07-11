import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';
import 'package:fairsplit/features/shopping/presentation/viewmodels/shopping_list_view_model.dart';
import 'package:fairsplit/core/utils/validators.dart';

class ShoppingListDetailPage extends ConsumerStatefulWidget {
  final String listId;

  const ShoppingListDetailPage({super.key, required this.listId});

  @override
  ConsumerState<ShoppingListDetailPage> createState() =>
      _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState
    extends ConsumerState<ShoppingListDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load shopping list details when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shoppingListDetailViewModelProvider.notifier)
          .getShoppingListDetail(widget.listId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListState = ref.watch(shoppingListDetailViewModelProvider);

    // Listen for errors and show snackbar
    ref.listen<AsyncValue<ShoppingList>>(shoppingListDetailViewModelProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
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
        title: shoppingListState.when(
          data: (shoppingList) => Text(
            shoppingList.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          loading: () =>
              const Text('Loading...', style: TextStyle(color: Colors.black)),
          error: (error, stack) => const Text(
            'Shopping List',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showListMenu(context),
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: shoppingListState.when(
        data: (shoppingList) => _buildShoppingListContent(shoppingList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Không thể tải danh sách',
                style: TextStyle(color: Colors.red[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .read(shoppingListDetailViewModelProvider.notifier)
                    .refreshShoppingListDetail(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: const Color(0xFF87CEEB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildShoppingListContent(ShoppingList shoppingList) {
    return Column(
      children: [
        // List info section with integrated financial summary
        _buildListInfo(shoppingList),

        // Items section
        Expanded(child: _buildItemsSection(shoppingList)),
      ],
    );
  }

  Widget _buildListInfo(ShoppingList shoppingList) {
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
          Text(
            shoppingList.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            shoppingList.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Combined Shopping Info Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: const Color(0xFF4A90E2),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông tin mua sắm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildFinanceCard(
                        'Đã mua',
                        '${shoppingList.items.where((item) => item.isPurchased).length}/${shoppingList.items.length}',
                        _formatCurrency(_calculateActualTotal(shoppingList)),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _buildFinanceCard(
                        'Còn lại',
                        '${shoppingList.items.where((item) => !item.isPurchased).length} mặt hàng',
                        _formatCurrency(_calculateRemainingTotal(shoppingList)),
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _buildFinanceCard(
                        'Tổng cần mua',
                        '${shoppingList.items.length} mặt hàng',
                        _formatCurrency(_calculateEstimatedTotal(shoppingList)),
                        const Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (shoppingList.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: shoppingList.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF87CEEB),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsSection(ShoppingList shoppingList) {
    if (shoppingList.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có mặt hàng nào',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm mặt hàng đầu tiên vào danh sách',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Group items by category
    final Map<String, List<ShoppingItem>> groupedItems = {};
    for (final item in shoppingList.items) {
      groupedItems.putIfAbsent(item.category ?? 'Other', () => []).add(item);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mặt hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => ref
                    .read(shoppingListDetailViewModelProvider.notifier)
                    .refreshShoppingListDetail(),
                child: const Text('Làm mới'),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(shoppingListDetailViewModelProvider.notifier)
                  .refreshShoppingListDetail(),
              color: const Color(0xFF87CEEB),
              child: ListView.builder(
                itemCount: groupedItems.keys.length,
                itemBuilder: (context, index) {
                  final category = groupedItems.keys.elementAt(index);
                  final categoryItems = groupedItems[category]!;
                  return _buildCategorySection(category, categoryItems);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ShoppingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF87CEEB),
            ),
          ),
        ),
        ...items.map((item) => _buildItemCard(item)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItemCard(ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isPurchased
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showItemMenu(context, item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(shoppingListDetailViewModelProvider.notifier)
                      .toggleItemPurchased(item.id, !item.isPurchased),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.isPurchased
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(
                        color: item.isPurchased ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: item.isPurchased
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: item.isPurchased
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isPurchased ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(item.estimatedPrice ?? 0).toStringAsFixed(0)} VND',
                            style: TextStyle(
                              color: item.isPurchased
                                  ? Colors.green
                                  : const Color(0xFF87CEEB),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isPurchased
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isPurchased ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                    style: TextStyle(
                      color: item.isPurchased ? Colors.green : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showListMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa danh sách'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit list page
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ danh sách'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Lưu trữ danh sách'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(shoppingListDetailViewModelProvider.notifier)
                    .archiveList();
              },
            ),
          ],
        );
      },
    );
  }

  void _showItemMenu(BuildContext context, ShoppingItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa mặt hàng'),
              onTap: () {
                Navigator.pop(context);
                _showEditItemDialog(context, item);
              },
            ),
            ListTile(
              leading: Icon(
                item.isPurchased
                    ? Icons.remove_shopping_cart
                    : Icons.shopping_cart,
              ),
              title: Text(
                item.isPurchased ? 'Đánh dấu chưa mua' : 'Đánh dấu đã mua',
              ),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(shoppingListDetailViewModelProvider.notifier)
                    .toggleItemPurchased(item.id, !item.isPurchased);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Xóa mặt hàng',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteItemDialog(context, item);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddItemsDialog(
          onItemsAdded: (items) {
            if (items.isNotEmpty) {
              final request = CreateShoppingItemsRequest(items: items);
              ref
                  .read(shoppingListDetailViewModelProvider.notifier)
                  .addItems(request);
            }
          },
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, ShoppingItem item) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final unitController = TextEditingController(text: item.unit);
    final priceController = TextEditingController(
      text: item.estimatedPrice.toString(),
    );
    final categoryController = TextEditingController(text: item.category);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa mặt hàng'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Tên mặt hàng',
                      prefixIcon: Icon(Icons.shopping_cart),
                    ),
                    validator: Validators.validateItemName,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            hintText: 'Số lượng',
                            prefixIcon: Icon(Icons.format_list_numbered),
                          ),
                          keyboardType: TextInputType.number,
                          validator: Validators.validateQuantity,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            hintText: 'Đơn vị',
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          validator: (value) =>
                              value?.isEmpty == true ? 'Bắt buộc' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      hintText: 'Giá dự kiến',
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePrice,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      hintText: 'Danh mục',
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: Validators.validateCategory,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final request = UpdateShoppingItemRequest(
                    name: nameController.text,
                    quantity: int.parse(quantityController.text),
                    unit: unitController.text,
                    estimatedPrice: double.parse(priceController.text),
                    category: categoryController.text,
                  );

                  ref
                      .read(shoppingListDetailViewModelProvider.notifier)
                      .updateItem(item.id, request);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
              ),
              child: const Text(
                'Cập nhật',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteItemDialog(BuildContext context, ShoppingItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(shoppingListDetailViewModelProvider.notifier)
                    .deleteItem(item.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  double _calculateActualTotal(ShoppingList shoppingList) {
    return shoppingList.items.where((item) => item.isPurchased).fold(0.0, (
      sum,
      item,
    ) {
      final price = item.actualPrice ?? item.estimatedPrice ?? 0.0;
      return sum + price;
    });
  }

  double _calculateEstimatedTotal(ShoppingList shoppingList) {
    return shoppingList.items.fold(0.0, (sum, item) {
      final price = item.estimatedPrice ?? 0.0;
      return sum + price;
    });
  }

  double _calculateRemainingTotal(ShoppingList shoppingList) {
    return shoppingList.items.where((item) => !item.isPurchased).fold(0.0, (
      sum,
      item,
    ) {
      final price = item.estimatedPrice ?? 0.0;
      return sum + price;
    });
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

  // Removed unused _buildShoppingListHeader method

  // Removed unused _buildFinancialSummary method

  Widget _buildFinanceCard(
    String title,
    String subtitle,
    String amount,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AddItemsDialog extends StatefulWidget {
  final Function(List<CreateShoppingItemRequest>) onItemsAdded;

  const _AddItemsDialog({required this.onItemsAdded});

  @override
  State<_AddItemsDialog> createState() => _AddItemsDialogState();
}

class _AddItemsDialogState extends State<_AddItemsDialog> {
  final List<_ItemInput> _items = [_ItemInput()];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDialogHeight = screenHeight * 0.8; // 80% của màn hình
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: maxDialogHeight, minHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB).withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFF87CEEB),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thêm mặt hàng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_items.length} mặt hàng',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF87CEEB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Quick add buttons
                      _buildQuickAddButtons(),
                      const SizedBox(height: 16),

                      // Items list
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            return _buildItemInput(index);
                          },
                        ),
                      ),

                      // Add button
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addNewItem,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Thêm mặt hàng khác'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF87CEEB),
                            side: const BorderSide(color: Color(0xFF87CEEB)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87CEEB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Thêm tất cả',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInput(int index) {
    final item = _items[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với số thứ tự và nút xóa
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Mặt hàng ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                if (_items.length > 1)
                  InkWell(
                    onTap: () => _removeItem(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Tên mặt hàng
            TextFormField(
              controller: item.nameController,
              decoration: InputDecoration(
                labelText: 'Tên mặt hàng *',
                hintText: 'Ví dụ: Sữa tươi, Bánh mì...',
                prefixIcon: const Icon(
                  Icons.shopping_cart,
                  color: Color(0xFF87CEEB),
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              validator: (value) =>
                  value?.isEmpty == true ? 'Vui lòng nhập tên mặt hàng' : null,
            ),
            const SizedBox(height: 12),

            // Số lượng và đơn vị
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.quantityController,
                    decoration: InputDecoration(
                      labelText: 'Số lượng *',
                      hintText: '1',
                      prefixIcon: const Icon(
                        Icons.format_list_numbered,
                        color: Color(0xFF87CEEB),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF87CEEB),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Bắt buộc';
                      if (int.tryParse(value!) == null)
                        return 'Số không hợp lệ';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: item.unitController,
                    decoration: InputDecoration(
                      labelText: 'Đơn vị',
                      hintText: 'hộp, kg, chai...',
                      prefixIcon: const Icon(
                        Icons.straighten,
                        color: Color(0xFF87CEEB),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF87CEEB),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Giá dự kiến
            TextFormField(
              controller: item.priceController,
              decoration: InputDecoration(
                labelText: 'Giá dự kiến (VND)',
                hintText: '15000',
                prefixIcon: const Icon(
                  Icons.monetization_on,
                  color: Color(0xFF87CEEB),
                  size: 20,
                ),
                suffixText: 'VND',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF87CEEB),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isNotEmpty == true &&
                    double.tryParse(value!) == null) {
                  return 'Giá không hợp lệ';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _items.add(_ItemInput());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  void _submitItems() {
    if (_formKey.currentState!.validate()) {
      final requests = _items
          .where((item) => item.nameController.text.isNotEmpty)
          .map(
            (item) => CreateShoppingItemRequest(
              name: item.nameController.text.trim(),
              quantity: int.parse(item.quantityController.text),
              unit: item.unitController.text.trim().isNotEmpty
                  ? item.unitController.text.trim()
                  : null,
              estimatedPrice: item.priceController.text.isNotEmpty
                  ? double.parse(item.priceController.text)
                  : null,
            ),
          )
          .toList();

      if (requests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập ít nhất một mặt hàng'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      widget.onItemsAdded(requests);
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${requests.length} mặt hàng vào danh sách'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addPresetItem(String name, int quantity, String unit, double? price) {
    setState(() {
      final newItem = _ItemInput();
      newItem.nameController.text = name;
      newItem.quantityController.text = quantity.toString();
      newItem.unitController.text = unit;
      if (price != null) {
        newItem.priceController.text = price.toString();
      }
      _items.add(newItem);
    });
  }

  Widget _buildQuickAddButtons() {
    final presetItems = [
      {'name': 'Sữa tươi', 'quantity': 1, 'unit': 'hộp', 'price': 15000.0},
      {'name': 'Bánh mì', 'quantity': 2, 'unit': 'ổ', 'price': 8000.0},
      {'name': 'Trứng gà', 'quantity': 10, 'unit': 'quả', 'price': 3000.0},
      {'name': 'Rau xanh', 'quantity': 1, 'unit': 'kg', 'price': 25000.0},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB).withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF87CEEB).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  size: 16,
                  color: Colors.orange[600],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Thêm nhanh:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presetItems.map((item) {
              return InkWell(
                onTap: () => _addPresetItem(
                  item['name'] as String,
                  item['quantity'] as int,
                  item['unit'] as String,
                  item['price'] as double?,
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF87CEEB).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 16,
                        color: const Color(0xFF87CEEB),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF87CEEB),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }
}

class _ItemInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController unitController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    priceController.dispose();
  }
}
