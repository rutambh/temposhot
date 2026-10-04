import 'package:flutter/material.dart';

/// The primary action control.
///
/// Keeps the original tactile behaviour -- it physically depresses and its
/// shadow collapses -- but the finish is now flat ink on paper rather than the
/// old moulded-plastic gradient, which is what made it read as skeuomorphic
/// next to the notebook surfaces.
class TactilePusherButton3D extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double fontSize;

  const TactilePusherButton3D({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.height = 64.0,
    this.fontSize = 17.0,
  });

  @override
  State<TactilePusherButton3D> createState() => _TactilePusherButton3DState();
}

class _TactilePusherButton3DState extends State<TactilePusherButton3D> {
  bool _isPressed = false;

  static const double _travel = 4.0;
  static const Duration _duration = Duration(milliseconds: 70);

  @override
  Widget build(BuildContext context) {
    final depth = _isPressed ? 0.0 : _travel;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: _duration,
        height: widget.height,
        transform: Matrix4.translationValues(0, _isPressed ? _travel : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.backgroundColor,
          border: Border.all(
            color: widget.backgroundColor.withValues(alpha: 0.0),
          ),
          boxShadow: [
            // Solid extrusion: the same hue, darkened, so the button looks
            // pressed into the page rather than floating on it.
            BoxShadow(
              color: Color.lerp(widget.backgroundColor, Colors.black, 0.45)!
                  .withValues(alpha: _isPressed ? 0.0 : 1.0),
              blurRadius: 0,
              offset: Offset(0, depth + 3),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 22, color: widget.textColor),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}