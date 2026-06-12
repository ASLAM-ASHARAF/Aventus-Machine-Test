import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/theme_state.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../theme_providers.dart';



class ThemeController extends Notifier<ThemeState> {
  ThemeRepository get _repository => ref.read(themeRepositoryProvider);

  @override
  ThemeState build() => _repository.load();

 

  void toggleTheme() {
    final ThemeMode next = switch (state.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system =>

        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark,
    };
    setThemeMode(next);
  }

  void setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  void changeColor(Color color) =>
      _update(state.copyWith(primaryColor: color));

  void changeFont(String fontFamily) =>
      _update(state.copyWith(fontFamily: fontFamily));

  void _update(ThemeState next) {
    if (next == state) return;
    state = next;
  

    unawaited(
      _repository.save(next).catchError(
        (Object error, StackTrace _) =>
            debugPrint('⚠️ Failed to persist theme: $error'),
      ),
    );
  }
}

final NotifierProvider<ThemeController, ThemeState> themeControllerProvider =
    NotifierProvider<ThemeController, ThemeState>(ThemeController.new);
