import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/ballistic_theme.dart';
import '../../core/theme/theme_mode_provider.dart';

/// Tactile toggle button for switching between Light and Dark mode.
class ThemeModeToggleButton extends ConsumerWidget {
  const ThemeModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = BallisticTokens.of(context);
    final currentMode = ref.watch(themeModeProvider);

    final isDark = currentMode == ThemeMode.dark ||
        (currentMode == ThemeMode.system && tokens.isDark);

    return Semantics(
      button: true,
      label: 'Toggle theme mode',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () => ref.read(themeModeProvider.notifier).toggle(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: tokens.border, width: 1.5),
            ),
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: tokens.text,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
