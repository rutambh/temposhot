import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_flavor.dart';
import 'core/database/database_factory.dart';
import 'core/theme/ballistic_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure SQLite factory (native on Android, WASM/IndexedDB on web)
  configureDatabaseFactory();

  // Detect flavor from `--dart-define=FLAVOR=lite|pro`
  AppFlavorConfig.fromEnvironment();

  runApp(
    const ProviderScope(
      child: TempoShotApp(),
    ),
  );
}

class TempoShotApp extends ConsumerWidget {
  final bool showStartupDisclaimer;

  const TempoShotApp({
    super.key,
    this.showStartupDisclaimer = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final flavor = ref.watch(flavorConfigProvider);

    return MaterialApp(
      title: flavor.appName,
      debugShowCheckedModeBanner: false,
      theme: createBallisticThemeData(BallisticTokens.light),
      darkTheme: createBallisticThemeData(BallisticTokens.dark),
      themeMode: themeMode,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final tokens = brightness == Brightness.dark
            ? BallisticTokens.dark
            : BallisticTokens.light;

        return BallisticTheme(
          tokens: tokens,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: DashboardScreen(showStartupDisclaimer: showStartupDisclaimer),
    );
  }
}
