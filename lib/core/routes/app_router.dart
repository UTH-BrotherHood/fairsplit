import 'package:fairsplit/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:fairsplit/features/auth/presentation/views/login_page.dart';
import 'package:fairsplit/features/home/presentation/pages/home_page.dart';
import 'package:fairsplit/features/profile/presentation/pages/profile_page.dart';
import 'package:fairsplit/features/setting/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = auth != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) return isLoggingIn ? null : '/login';
      if (isLoggingIn && isLoggedIn) return '/';
      return null;
    },

    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePageWrapper(),
      ),
      GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
    ],
  );
});

class ProfilePageWrapper extends ConsumerWidget {
  const ProfilePageWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider);
    if (user == null) return const SizedBox();
    return ProfilePage();
  }
}
