import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/field_notebook_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/widgets/dot_grid_background.dart';
import 'data/datasources/database_factory.dart';
import 'presentation/dashboard/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mobile keeps sqflite's native factory; the web preview switches to the
  // WASM/IndexedDB factory so the logbook works in a browser too.
  configureDatabaseFactory();

  runApp(const ProviderScope(child: TempoShotApp()));
}

class TempoShotApp extends ConsumerWidget {
  const TempoShotApp({super.key, this.showStartupDisclaimer = true});

  /// Disabled by widget tests that capture the screens in isolation.
  final bool showStartupDisclaimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'TempoShot',
      debugShowCheckedModeBanner: false,
      theme: fieldNotebookTheme(FieldNotebookTokens.light),
      darkTheme: fieldNotebookTheme(FieldNotebookTokens.dark),
      themeMode: themeMode,
      // The shell, not `home:` -- `builder` sits above the Navigator, so every
      // pushed route gets the same tokens and the same dot-grid paper. Wrapping
      // `home:` alone left the live timer and summary on bare scaffold colour.
      builder:
          (context, child) => FieldNotebookTheme(
            tokens: FieldNotebookTokens.of(context),
            child: DotGridBackground(child: child ?? const SizedBox.shrink()),
          ),
      home: DashboardScreen(showStartupDisclaimer: showStartupDisclaimer),
    );
  }
}
