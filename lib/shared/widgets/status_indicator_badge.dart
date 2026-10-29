import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/ballistic_theme.dart';

/// Chamfered tactical status pill with high-visibility indicator dot.
class StatusIndicatorBadge extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isPulsing;

  const StatusIndicatorBadge({
    super.key,
    required this.label,
    this.dotColor,
    this.backgroundColor,
    this.textColor,
    this.isPulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);
    final dot = dotColor ?? tokens.primary;
    final bg = backgroundColor ?? tokens.surfaceSub;
    final txt = textColor ?? tokens.text;

    return Container(
      height: AppSpacing.statusBadgeHeight,
      padding: AppSpacing.badgePadding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: tokens.borderStrong, width: 1.0),
      ),
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: isPulsing
                  ? [
                      BoxShadow(
                        color: dot.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.0,
                color: txt,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
