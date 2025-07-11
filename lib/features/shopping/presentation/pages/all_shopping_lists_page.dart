import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';
import 'package:fairsplit/features/shopping/presentation/viewmodels/shopping_list_view_model.dart';
import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';
import 'package:fairsplit/features/shopping/presentation/pages/shopping_list_detail_page.dart';
import 'package:fairsplit/features/shopping/presentation/pages/create_shopping_list_page.dart';

class AllShoppingListsPage extends ConsumerStatefulWidget {
  final String? initialGroupId;
  final String? initialGroupName;
  final bool showCreateForm;

  const AllShoppingListsPage({
    super.key,
    this.initialGroupId,
    this.initialGroupName,
    this.showCreateForm = false,
  });

  @override
  ConsumerState<AllShoppingListsPage> createState() =>
      _AllShoppingListsPageState();
}

class _AllShoppingListsPageState extends ConsumerState<AllShoppingListsPage>
    with WidgetsBindingObserver {
  Map<String, List<ShoppingList>> groupShoppingLists = {};
  bool isLoading = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllShoppingLists();
      // Show create form automatically if requested
      if (widget.showCreateForm && widget.initialGroupId != null) {
        _showCreateShoppingListDialog(widget.initialGroupId!);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // Clear the state to prevent potential memory leaks
    groupShoppingLists.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isDisposed && mounted) {
      // Refresh data when app comes back to foreground
      _loadAllShoppingLists();
    }
  }

  Future<void> _loadAllShoppingLists() async {
    if (_isDisposed || !mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Get all groups first
      await ref.read(groupViewModelProvider.notifier).getMyGroups();

      if (_isDisposed || !mounted) return;

      final groupsState = ref.read(groupViewModelProvider);

      if (groupsState.hasValue) {
        final groups = groupsState.value!.items;
        Map<String, List<ShoppingList>> allLists = {};

        // Load shopping lists for each group
        for (final group in groups) {
          if (_isDisposed || !mounted) return;

          try {
            await ref
                .read(shoppingListsViewModelProvider.notifier)
                .getShoppingLists(group.id);

            if (_isDisposed || !mounted) return;

            final listsState = ref.read(shoppingListsViewModelProvider);

            if (listsState.hasValue) {
              allLists[group.name] = listsState.value!;
            }
          } catch (e) {
            // Continue with other groups if one fails
            debugPrint(
              'Failed to load shopping lists for group ${group.name}: $e',
            );
          }
        }

        if (!_isDisposed && mounted) {
          setState(() {
            groupShoppingLists = allLists;
          });
        }
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải danh sách: $e')));
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
          'Shopping Lists',
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
                _loadAllShoppingLists();
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllShoppingLists,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : groupShoppingLists.isEmpty
            ? _buildEmptyState()
            : _buildShoppingListsView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_isDisposed && mounted) {
            _showCreateShoppingListDialog();
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
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có shopping list nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo shopping list đầu tiên để bắt đầu',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (!_isDisposed && mounted) {
                _showCreateShoppingListDialog();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo Shopping List'),
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

  Widget _buildShoppingListsView() {
    return RefreshIndicator(
      onRefresh: _loadAllShoppingLists,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...groupShoppingLists.entries.map((entry) {
            final groupName = entry.key;
            final lists = entry.value;

            if (lists.isEmpty) return const SizedBox.shrink();

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
                          '${lists.length}',
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
                ...lists.map((list) => _buildShoppingListCard(list)),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildShoppingListCard(ShoppingList shoppingList) {
    final completedItems = shoppingList.items
        .where((item) => item.isPurchased)
        .length;
    final totalItems = shoppingList.items.length;
    final completionPercentage = totalItems > 0
        ? (completedItems / totalItems)
        : 0.0;

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
                builder: (context) =>
                    ShoppingListDetailPage(listId: shoppingList.id),
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
                    Expanded(
                      child: Text(
                        shoppingList.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    _buildStatusChip(_getShoppingListStatus(shoppingList)),
                  ],
                ),
                if (shoppingList.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    shoppingList.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completionPercentage == 1.0
                              ? Colors.green
                              : const Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedItems/$totalItems',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalItems mặt hàng',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatShoppingListPrice(shoppingList),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    if (shoppingList.dueDate != null) ...[
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(shoppingList.dueDate!),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatShoppingListPrice(ShoppingList shoppingList) {
    double total = 0.0;
    for (var item in shoppingList.items) {
      final price = item.estimatedPrice ?? 0.0;
      total += price; // Fixed price per item, no quantity multiplication
    }

    if (total >= 1000000) {
      return '${(total / 1000000).toStringAsFixed(1)}M VND';
    } else if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(0)}K VND';
    } else {
      return '${total.toStringAsFixed(0)} VND';
    }
  }

  String _getShoppingListStatus(ShoppingList shoppingList) {
    if (shoppingList.items.isEmpty) {
      return 'pending'; // Chưa có items
    }

    final purchasedItems = shoppingList.items
        .where((item) => item.isPurchased)
        .length;
    final totalItems = shoppingList.items.length;

    if (purchasedItems == totalItems) {
      return 'completed'; // Đã mua đủ
    } else {
      return 'in_progress'; // Chưa mua hết
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        displayText = 'Đã mua đủ';
        break;
      case 'in_progress':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        displayText = 'Chưa mua hết';
        break;
      case 'archived':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
        displayText = 'Đã lưu trữ';
        break;
      default:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue[700]!;
        displayText = 'Chưa có mặt hàng';
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateShoppingListDialog([String? selectedGroupId]) {
    // If a specific group is provided, navigate directly to create page
    if (selectedGroupId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreateShoppingListPage(groupId: selectedGroupId),
        ),
      ).then((result) {
        if (result == true && !_isDisposed && mounted) {
          _loadAllShoppingLists();
        }
      });
      return;
    }

    final groupsState = ref.read(groupViewModelProvider);

    if (!groupsState.hasValue || groupsState.value!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần có ít nhất một nhóm để tạo shopping list'),
        ),
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
                        builder: (context) =>
                            CreateShoppingListPage(groupId: group.id),
                      ),
                    ).then((result) {
                      if (result == true && !_isDisposed && mounted) {
                        _loadAllShoppingLists();
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
}
