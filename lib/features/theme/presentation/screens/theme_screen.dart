import 'package:flutter/material.dart';

import '../widgets/accent_color_picker.dart';
import '../widgets/font_family_selector.dart';
import '../widgets/theme_mode_selector.dart';
import '../widgets/theme_preview_card.dart';



class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const <Widget>[
          _RebuildHint(),
          ThemePreviewCard(),
          ThemeModeSelector(),
          AccentColorPicker(),
          FontFamilySelector(),
        ],
      ),
    );
  }
}

class _RebuildHint extends StatelessWidget {
  const _RebuildHint();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.bolt, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Each badge counts that section\'s rebuilds. Change one setting '
              'and only the relevant section — plus the live preview — ticks up.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
