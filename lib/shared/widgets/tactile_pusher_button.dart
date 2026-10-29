import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/ballistic_theme.dart';

enum PusherVariant {
  primary,   // Blaze Orange
  secondary, // Surface Olive / Sand
  danger,    // Oxide Alert Red
}

/// Glove-friendly tactical mechanical pusher button with 3D tactile offset shadow
/// and spring-action pressed feedback.
class TactilePusherButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final PusherVariant variant;
  final double height;
  final bool isFullWidth;

  const TactilePusherButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = PusherVariant.primary,
    this.height = AppSpacing.primaryButtonHeight,
    this.isFullWidth = true,
  });

  @override
  State<TactilePusherButton> createState() => _TactilePusherButtonState();
}

class _TactilePusherButtonState extends State<TactilePusherButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);
    final isEnabled = widget.onPressed != null;

    Color fillColor;
    Color borderColor;
    Color shadowColor;
    Color textColor;

    switch (widget.variant) {
      case PusherVariant.primary:
        fillColor = isEnabled ? tokens.primary : tokens.surfaceSub;
        borderColor = isEnabled ? tokens.primaryHover : tokens.border;
        shadowColor = isEnabled ? tokens.primaryShadow : Colors.transparent;
        textColor = isEnabled ? Colors.white : tokens.textMuted;
        break;
      case PusherVariant.secondary:
        fillColor = isEnabled ? tokens.surfaceSub : tokens.surface;
        borderColor = isEnabled ? tokens.borderStrong : tokens.border;
        shadowColor = isEnabled ? tokens.chassisShadow : Colors.transparent;
        textColor = isEnabled ? tokens.text : tokens.textMuted;
        break;
      case PusherVariant.danger:
        fillColor = isEnabled ? tokens.alert : tokens.surfaceSub;
        borderColor = isEnabled ? tokens.primaryHover : tokens.border;
        shadowColor = isEnabled ? tokens.primaryShadow : Colors.transparent;
        textColor = isEnabled ? Colors.white : tokens.textMuted;
        break;
    }

    final shadowOffset = _isPressed ? 1.0 : 4.0;
    final translateY = _isPressed ? 3.0 : 0.0;

    Widget buttonContent = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 22, color: textColor),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.8,
              color: textColor,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          transform: Matrix4.translationValues(0, translateY, 0),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: borderColor, width: 2.0),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: shadowColor,
                      offset: Offset(0, shadowOffset),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: buttonContent,
        ),
      ),
    );
  }
}
