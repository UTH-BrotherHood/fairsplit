import 'package:fairsplit/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:fairsplit/features/home/presentation/widgets/home_screen.dart';
import 'package:fairsplit/features/home/presentation/widgets/analytics_screen.dart';
import 'package:fairsplit/features/home/presentation/widgets/expenses_screen.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';
import 'package:fairsplit/features/expenses/presentation/pages/add_expense_page.dart';
import 'package:fairsplit/injection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pages = [
  const HomeScreen(),
  const AnalyticsScreen(),
  const ExpensesScreen(),
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _showSettingsMenu(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                if (user != null) {
                  context.push('/profile');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authViewModelProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[selectedPage],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: Colors.transparent,
            elevation: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: selectedPage == 0,
                    onTap: () =>
                        ref.read(selectedPageProvider.notifier).state = 0,
                  ),
                  _buildNavItem(
                    icon: Icons.analytics_rounded,
                    label: 'Analytics',
                    isSelected: selectedPage == 1,
                    onTap: () =>
                        ref.read(selectedPageProvider.notifier).state = 1,
                  ),
                  const SizedBox(width: 60), // Space for FAB
                  _buildNavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Expenses',
                    isSelected: selectedPage == 2,
                    onTap: () =>
                        ref.read(selectedPageProvider.notifier).state = 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    isSelected: selectedPage == 3,
                    onTap: () => _showSettingsMenu(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF87CEEB), Color(0xFF5F9FBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF87CEEB).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          tooltip: 'Add Expense',
          heroTag: 'add-expense',
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () => _showAddExpenseDialog(context),
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF87CEEB).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF87CEEB) : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF87CEEB) : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _AddExpenseDialog());
  }
}

class _AddExpenseDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupViewModelProvider);

    return AlertDialog(
      title: const Text('Thêm chi tiêu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Chọn nhóm để thêm chi tiêu:'),
          const SizedBox(height: 16),
          groupsState.when(
            data: (groupsResponse) {
              if (groupsResponse.items.isEmpty) {
                return Column(
                  children: [
                    const Text('Bạn chưa có nhóm nào.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/create-group');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87CEEB),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Tạo nhóm mới'),
                    ),
                  ],
                );
              }

              return SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: groupsResponse.items.length,
                  itemBuilder: (context, index) {
                    final group = groupsResponse.items[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF87CEEB),
                        child: Text(
                          group.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(group.name),
                      subtitle: Text(group.description),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddExpensePage(group: group),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Lỗi: $error'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}
