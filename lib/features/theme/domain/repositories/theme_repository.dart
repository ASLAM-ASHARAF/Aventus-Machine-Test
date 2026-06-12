import '../entities/theme_state.dart';


abstract interface class ThemeRepository {
  ThemeState load();

  Future<void> save(ThemeState state);
}
