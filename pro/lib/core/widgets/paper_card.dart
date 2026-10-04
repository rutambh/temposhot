import 'package:flutter/material.dart';

import '../theme/field_notebook_theme.dart';

/// The Field Notebook surface: cream card, hairline border, one soft shadow
/// tinted to the paper hue rather than pure black.
class PaperCard extends StatelessWidget {
  const PaperCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.opacity = 0.88,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Cards sit slightly translucent so the dot grid reads faintly through,
  /// which is what stops the page looking like stacked boxes.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    final dark = tokens.brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: dark
                ? const Color(0xFF000000).withValues(alpha: 0.28)
                : const Color(0xFF2A2A1A).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
