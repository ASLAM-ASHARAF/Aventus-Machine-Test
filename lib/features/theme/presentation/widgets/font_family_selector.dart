import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../shared/widgets/rebuild_counter.dart';
import '../../domain/entities/theme_state.dart';
import '../controllers/theme_controller.dart';
import 'settings_section.dart';



class FontFamilySelector extends ConsumerWidget {
  const FontFamilySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String selected = ref.watch(
      themeControllerProvider.select((ThemeState s) => s.fontFamily),
    );

    return SettingsSection(
      title: 'Font',
      trailing: RebuildCounter(label: 'font', token: selected),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[

          for (final String family in AppFonts.families)
            ChoiceChip(

              label: Text(family, style: GoogleFonts.getFont(family)),
              selected: family == selected,
              onSelected: (_) => ref
              
                  .read(themeControllerProvider.notifier)
                  .changeFont(family),
            ),
        ],
      ),
    );
  }
}
