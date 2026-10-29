import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/ballistic_theme.dart';

/// Mil-spec tactical container surface with layered borders, subtle inner highlight,
/// and tactical drop shadow.
class BallisticCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? surfaceColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool hasShadow;

  const BallisticCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.margin = EdgeInsets.zero,
    this.surfaceColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.borderRadius = AppSpacing.radiusLg,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);
    final fill = surfaceColor ?? tokens.surface;
    final border = borderColor ?? tokens.border;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: tokens.chassisShadow.withValues(alpha: tokens.isDark ? 0.6 : 0.8),
                  offset: const Offset(0, 4),
                  blurRadius: 0, // Flat tactile offset shadow
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: tokens.topHighlight.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
