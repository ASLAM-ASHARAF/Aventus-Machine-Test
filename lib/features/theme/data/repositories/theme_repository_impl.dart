import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/theme_state.dart';
import '../../domain/repositories/theme_repository.dart';



class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._box);

  final Box _box;

  @override
  ThemeState load() {
    final String? modeName = _box.get(AppConstants.themeModeKey) as String?;
    final int? colorValue = _box.get(AppConstants.primaryColorKey) as int?;
    final String? fontFamily = _box.get(AppConstants.fontFamilyKey) as String?;

    return ThemeState(
      themeMode: modeName != null
          ? ThemeMode.values.byName(modeName)
          : ThemeMode.system,
      primaryColor: colorValue != null
          ? Color(colorValue)
          : AppPalette.defaultSeed,
      fontFamily: fontFamily ?? AppFonts.defaultFamily,
    );
  }

  @override
  Future<void> save(ThemeState state) async {
    await _box.putAll(<String, dynamic>{
      AppConstants.themeModeKey: state.themeMode.name,
      AppConstants.primaryColorKey: state.primaryColor.toARGB32(),
      AppConstants.fontFamilyKey: state.fontFamily,
    });
  }
}
