import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/hive/hive_registrar.g.dart';
import 'features/posts/data/models/post_model.dart';
import 'shared/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Hive bootstrap -------------------------------------------------------
  await Hive.initFlutter();
  Hive.registerAdapters(); // generated extension (see core/hive/hive_registrar.g.dart)

  final Box settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  final Box<PostModel> postsBox =
      await Hive.openBox<PostModel>(AppConstants.postsBoxName);

  // --- Dependency injection -------------------------------------------------
  // The opened boxes are the only truly async singletons; we inject them into
  // the Riverpod graph via overrides so the rest of the app can read them
  // synchronously.
  runApp(
    ProviderScope(
      overrides: [
        settingsBoxProvider.overrideWithValue(settingsBox),
        postsBoxProvider.overrideWithValue(postsBox),
      ],
      child: const App(),
    ),
  );
}
