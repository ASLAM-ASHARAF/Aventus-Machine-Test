import 'package:flutter/material.dart';

@immutable
class AccentOption {
  const AccentOption(this.name, this.color);

  final String name;
  final Color color;
}


class AppPalette {
  const AppPalette._();

  static const Color defaultSeed = Color(0xFF6750A4); // M3 baseline purple

  static const List<AccentOption> options = <AccentOption>[
    AccentOption('Indigo', Color(0xFF6750A4)),
    AccentOption('Ocean', Color(0xFF0061A4)),
    AccentOption('Emerald', Color(0xFF146C2E)),
    AccentOption('Sunset', Color(0xFFB3261E)),
    AccentOption('Amber', Color(0xFF8F4C00)),
    AccentOption('Magenta', Color(0xFF9A25AE)),
  ];
}
