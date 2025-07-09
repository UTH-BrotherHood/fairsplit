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
        // List info section
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
          Row(
            children: [
              _buildInfoCard(
                icon: Icons.shopping_cart,
                title: 'Mặt hàng',
                value: '${shoppingList.items.length}',
                subtitle:
                    '${shoppingList.items.where((item) => item.isPurchased).length} đã mua',
              ),
              const SizedBox(width: 12),
              _buildInfoCard(
                icon: Icons.monetization_on,
                title: 'Dự kiến',
                value: '${shoppingList.totalEstimatedPrice.toStringAsFixed(0)}',
                subtitle: 'VND',
              ),
              const SizedBox(width: 12),
              _buildInfoCard(
                icon: Icons.check_circle,
                title: 'Thực tế',
                value: '${shoppingList.totalActualPrice.toStringAsFixed(0)}',
                subtitle: 'VND',
              ),
            ],
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF87CEEB)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
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
                if (item.isPurchased)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Đã mua',
                      style: TextStyle(
                        color: Colors.green,
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
    return AlertDialog(
      title: Row(
        children: [
          const Text('Thêm mặt hàng'),
          const Spacer(),
          Text(
            '${_items.length} item${_items.length > 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return _buildItemInput(index);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addNewItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm mặt hàng'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF87CEEB),
                        side: const BorderSide(color: Color(0xFF87CEEB)),
                      ),
                    ),
                  ),
                ],
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
          onPressed: _submitItems,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF87CEEB),
          ),
          child: const Text(
            'Thêm tất cả',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildItemInput(int index) {
    final item = _items[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Mặt hàng ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_items.length > 1)
                  IconButton(
                    onPressed: () => _removeItem(index),
                    icon: const Icon(Icons.close, color: Colors.red),
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.nameController,
              decoration: const InputDecoration(
                hintText: 'Tên mặt hàng *',
                prefixIcon: Icon(Icons.shopping_cart),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) => value?.isEmpty == true ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.quantityController,
                    decoration: const InputDecoration(
                      hintText: 'Số lượng *',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
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
                  child: TextFormField(
                    controller: item.unitController,
                    decoration: const InputDecoration(
                      hintText: 'Đơn vị',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.priceController,
              decoration: const InputDecoration(
                hintText: 'Giá dự kiến (VND)',
                prefixIcon: Icon(Icons.monetization_on),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
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
              name: item.nameController.text,
              quantity: int.parse(item.quantityController.text),
              unit: item.unitController.text.isNotEmpty
                  ? item.unitController.text
                  : null,
              estimatedPrice: item.priceController.text.isNotEmpty
                  ? double.parse(item.priceController.text)
                  : null,
            ),
          )
          .toList();

      widget.onItemsAdded(requests);
      Navigator.pop(context);
    }
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
