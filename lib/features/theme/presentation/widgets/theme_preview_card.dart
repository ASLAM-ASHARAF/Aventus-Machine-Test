import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/rebuild_counter.dart';
import '../../domain/entities/theme_state.dart';
import '../controllers/theme_controller.dart';
import 'settings_section.dart';



class ThemePreviewCard extends ConsumerWidget {
  const ThemePreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeState state = ref.watch(themeControllerProvider);
    final TextTheme text = Theme.of(context).textTheme;

    return SettingsSection(
      title: 'Live preview',
      trailing: RebuildCounter(label: 'preview (full state)', token: state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('The quick brown fox', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text('jumps over the lazy dog', style: text.bodyLarge),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('Primary')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Mode: ${state.themeMode.name}   •   Font: ${state.fontFamily}',
            style: text.labelMedium,
          ),
        ],
      ),
    );
  }
}
