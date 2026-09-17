import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:physio_ghar/core/repository/persistence.dart';
import 'package:physio_ghar/core/router/app_router.dart';
import 'package:physio_ghar/core/theme/app_colors.dart';
import 'package:physio_ghar/core/theme/app_text_styles.dart';

void main() {
  runApp(const ProviderScope(child: PhysioGharApp()));
}

class PhysioGharApp extends ConsumerWidget {
  const PhysioGharApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(persistenceProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PhysioGhar',
      routerConfig: ref.watch(routerProvider),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pine),
        scaffoldBackgroundColor: AppColors.cream,
        textTheme: AppTextStyles.textTheme,
      ),
    );
  }
}
