import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme_factory.dart';
import 'features/posts/presentation/screens/home_screen.dart';
import 'features/theme/domain/entities/theme_state.dart';
import 'features/theme/presentation/controllers/theme_controller.dart';


class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeState themeState = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Aventus Machine Test',
      debugShowCheckedModeBanner: false,
      themeMode: themeState.themeMode,
      theme: AppThemeFactory.light(themeState),
      darkTheme: AppThemeFactory.dark(themeState),
      home: const HomeScreen(),
    );
  }
}
