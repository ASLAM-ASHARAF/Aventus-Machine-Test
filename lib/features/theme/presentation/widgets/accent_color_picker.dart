import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/rebuild_counter.dart';
import '../../domain/entities/theme_state.dart';
import '../controllers/theme_controller.dart';
import 'settings_section.dart';


class AccentColorPicker extends ConsumerWidget {
  const AccentColorPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color selected = ref.watch(
      themeControllerProvider.select((ThemeState s) => s.primaryColor),
    );

    return SettingsSection(
      title: 'Accent color',
      trailing: RebuildCounter(label: 'color', token: selected),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: <Widget>[
          for (final AccentOption option in AppPalette.options)
            _ColorDot(
              option: option,
              isSelected: option.color.toARGB32() == selected.toARGB32(),
              onTap: () => ref
                  .read(themeControllerProvider.notifier)
                  .changeColor(option.color),
            ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AccentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: option.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: option.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
