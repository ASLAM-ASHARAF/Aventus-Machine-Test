import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/rebuild_counter.dart';
import '../../domain/entities/theme_state.dart';
import '../controllers/theme_controller.dart';
import 'settings_section.dart';



class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(
      themeControllerProvider.select((ThemeState s) => s.themeMode),
    );

    return SettingsSection(
      title: 'Theme mode',
      trailing: RebuildCounter(label: 'mode', token: mode),
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: const <ButtonSegment<ThemeMode>>[
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto_outlined),
            label: Text('System'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Light'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Dark'),
          ),
        ],
        selected: <ThemeMode>{mode},
        onSelectionChanged: (Set<ThemeMode> selection) => ref
            .read(themeControllerProvider.notifier)
            .setThemeMode(selection.first),
      ),
    );
  }
}
