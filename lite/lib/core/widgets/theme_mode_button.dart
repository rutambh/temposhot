import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/field_notebook_theme.dart';
import '../theme/theme_mode_provider.dart';

/// Cycles System → Light → Dark → System. The icon is the current mode, so
/// one tap always changes the theme and the result is visible immediately.
class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FieldNotebookTheme.of(context);
    final mode = ref.watch(themeModeProvider);

    final (icon, currentLabel, nextLabel) = switch (mode) {
      ThemeMode.system => (Icons.brightness_auto_outlined, 'System', 'Light'),
      ThemeMode.light => (Icons.light_mode_outlined, 'Light', 'Dark'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Dark', 'System'),
    };

    return IconButton(
      icon: Icon(icon, color: tokens.text),
      tooltip: '$currentLabel theme — switch to $nextLabel',
      onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
    );
  }
}
