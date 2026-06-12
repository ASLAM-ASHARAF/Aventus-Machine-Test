import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_providers.dart';
import 'data/repositories/theme_repository_impl.dart';
import 'domain/repositories/theme_repository.dart';


final Provider<ThemeRepository> themeRepositoryProvider =
    Provider<ThemeRepository>(
      
  (ref) => ThemeRepositoryImpl(ref.watch(settingsBoxProvider)),
);
