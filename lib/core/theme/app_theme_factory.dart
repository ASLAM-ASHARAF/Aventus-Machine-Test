import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/theme/domain/entities/theme_state.dart';



class AppThemeFactory {
  const AppThemeFactory._();

  static ThemeData light(ThemeState state) =>
      _build(state, Brightness.light);

  static ThemeData dark(ThemeState state) => _build(state, Brightness.dark);

  static ThemeData _build(ThemeState state, Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: state.primaryColor,
      brightness: brightness,
    );

    final ThemeData base = ThemeData(

      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    return base.copyWith(
      textTheme: _textTheme(state.fontFamily, base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Resolves a Google Fonts text theme, falling back to the base theme if the
  /// family cannot be resolved (e.g. unknown name).
  static TextTheme _textTheme(String fontFamily, TextTheme base) {
    try {
      return GoogleFonts.getTextTheme(fontFamily, base);
    } catch (_) {
      return base;
    }
  }
}
