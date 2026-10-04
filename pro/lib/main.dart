import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/field_notebook_theme.dart';
import 'core/widgets/dot_grid_background.dart';
import 'presentation/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TempoShotApp()));
}

class TempoShotApp extends StatelessWidget {
  const TempoShotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempoShot',
      debugShowCheckedModeBanner: false,
      theme: fieldNotebookTheme(FieldNotebookTokens.light),
      darkTheme: fieldNotebookTheme(FieldNotebookTokens.dark),
      themeMode: ThemeMode.system,
      // The shell, not `home:` -- `builder` sits above the Navigator, so every
      // pushed route gets the same tokens and the same dot-grid paper. Wrapping
      // `home:` alone left the live timer and summary on bare scaffold colour.
      builder: (context, child) => FieldNotebookTheme(
        tokens: FieldNotebookTokens.of(context),
        child: DotGridBackground(child: child ?? const SizedBox.shrink()),
      ),
      home: const DashboardScreen(),
    );
  }
}