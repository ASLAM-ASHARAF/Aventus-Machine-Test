import 'package:aventus_machine_test/features/theme/domain/entities/theme_state.dart';
import 'package:aventus_machine_test/features/theme/domain/repositories/theme_repository.dart';
import 'package:aventus_machine_test/features/theme/presentation/controllers/theme_controller.dart';
import 'package:aventus_machine_test/features/theme/presentation/widgets/accent_color_picker.dart';
import 'package:aventus_machine_test/features/theme/presentation/widgets/theme_mode_selector.dart';
import 'package:aventus_machine_test/features/theme/presentation/widgets/theme_preview_card.dart';
import 'package:aventus_machine_test/features/theme/theme_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';




class _InMemoryThemeRepository implements ThemeRepository {
  ThemeState _state = const ThemeState(
    themeMode: ThemeMode.system,
    primaryColor: Color(0xFF6750A4),
    fontFamily: 'Inter',
  );

  int saveCount = 0;

  @override
  ThemeState load() => _state;

  @override
    Future<void> save(ThemeState state) async {
    saveCount++;
    _state = state;
  }
}

void main() {
  late _InMemoryThemeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _InMemoryThemeRepository();
    container = ProviderContainer(
      overrides: [
        themeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('initial state is loaded from the repository', () {
    final ThemeState state = container.read(themeControllerProvider);
    expect(state.themeMode, ThemeMode.system);
    expect(state.fontFamily, 'Inter');
  });

  test('changeColor / changeFont / setThemeMode mutate and persist', () {
    final ThemeController controller =
        container.read(themeControllerProvider.notifier);

    controller.setThemeMode(ThemeMode.dark);
    controller.changeColor(const Color(0xFF0061A4));
    controller.changeFont('Lato');

    final ThemeState state = container.read(themeControllerProvider);
    expect(state.themeMode, ThemeMode.dark);
    expect(state.primaryColor, const Color(0xFF0061A4));
    expect(state.fontFamily, 'Lato');
    expect(repository.saveCount, 3);
  });

  test('no-op updates do not persist or rebuild', () {
    final ThemeController controller =
        container.read(themeControllerProvider.notifier);

    final ThemeState before = container.read(themeControllerProvider);
    controller.setThemeMode(before.themeMode); // identical value
    expect(repository.saveCount, 0);
  });

  test('select() rebuilds only when the watched slice changes', () {
    int colorListens = 0;
    container.listen(
      themeControllerProvider.select((ThemeState s) => s.primaryColor),
      (Color? _, Color _) => colorListens++,
    );

    container.read(themeControllerProvider.notifier).changeFont('Poppins');
    expect(colorListens, 0);



    container.read(themeControllerProvider.notifier).changeColor(Colors.teal);
    expect(colorListens, 1);
  });

  testWidgets(
      'rebuild badges: changing one slice rebuilds only that section (+ preview)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const <Widget>[
                ThemeModeSelector(),
                AccentColorPicker(),
                ThemePreviewCard(),
              ],
            ),
          ),
        ),
      ),
    );



    expect(find.text('mode · 1'), findsOneWidget);
    expect(find.text('color · 1'), findsOneWidget);
    expect(find.text('preview (full state) · 1'), findsOneWidget);

    container
        .read(themeControllerProvider.notifier)
        .changeColor(const Color(0xFF146C2E));
    await tester.pump();

    


    expect(find.text('color · 2'), findsOneWidget);
    expect(find.text('preview (full state) · 2'), findsOneWidget);
    expect(find.text('mode · 1'), findsOneWidget);
  });
}
