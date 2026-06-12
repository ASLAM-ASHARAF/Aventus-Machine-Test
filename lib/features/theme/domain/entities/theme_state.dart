import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState({
    required ThemeMode themeMode,
    required Color primaryColor,
    required String fontFamily,
  }) = _ThemeState;
}
