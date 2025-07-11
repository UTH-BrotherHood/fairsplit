import 'package:fairsplit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/core/routes/app_router.dart';
import 'package:fairsplit/features/setting/presentation/providers/theme_provider.dart';
import 'package:fairsplit/shared/services/shared_prefs_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      key: ValueKey(themeColor),
      debugShowCheckedModeBanner: false,
      title: 'FairSplit',
      routerConfig: router,
      theme: AppTheme.lightTheme,
    );
  }
}
