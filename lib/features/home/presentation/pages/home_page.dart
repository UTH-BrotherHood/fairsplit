import 'package:fairsplit/features/home/presentation/widgets/home_screen.dart';
import 'package:fairsplit/features/home/presentation/widgets/expenses_screen.dart';
import 'package:fairsplit/features/home/presentation/widgets/groups_screen.dart';
import 'package:fairsplit/features/groups/presentation/pages/create_group_page.dart';
import 'package:fairsplit/features/profile/presentation/pages/profile_page.dart';
import 'package:fairsplit/features/expenses/presentation/pages/all_bills_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPageProvider = StateProvider<int>((ref) => 0);

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

final pages = [
  const HomeScreen(), // Home
  const AllBillsPage(), // Bills - now goes directly to All Bills
  const ExpensesScreen(), // Expenses
  const GroupsScreen(), // Groups
  const ProfilePage(),
  // const PlaceholderScreen(title: 'Profile'), // Profile
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[selectedPage]),
      floatingActionButton:
          selectedPage ==
              3 // Only show on Groups tab
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupPage(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF4A90E2),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: selectedPage == 0,
              onTap: () => ref.read(selectedPageProvider.notifier).state = 0,
            ),
            _buildNavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Bills',
              isSelected: selectedPage == 1,
              onTap: () => ref.read(selectedPageProvider.notifier).state = 1,
            ),
            _buildNavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Expenses',
              isSelected: selectedPage == 2,
              onTap: () => ref.read(selectedPageProvider.notifier).state = 2,
            ),
            _buildNavItem(
              icon: Icons.group_rounded,
              label: 'Groups',
              isSelected: selectedPage == 3,
              onTap: () => ref.read(selectedPageProvider.notifier).state = 3,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: selectedPage == 4,
              onTap: () => ref.read(selectedPageProvider.notifier).state = 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon với background tròn nếu được chọn
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4A90E2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[500],
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF4A90E2)
                      : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
