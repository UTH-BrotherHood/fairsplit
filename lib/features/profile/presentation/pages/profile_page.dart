import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/profile/presentation/viewmodels/profile_view_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (user) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${user.id}'),
                SizedBox(height: 8),
                Text('Name: ${user.name}'),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildStat(String title, int value) {
  //   return Column(
  //     children: [
  //       Text(
  //         value.toString(),
  //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //       ),
  //       Text(title),
  //     ],
  //   );
  // }
}
