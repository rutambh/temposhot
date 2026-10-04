import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    const double unpressedDepth = 6.0;
    final double depth = _isPressed ? 1.5 : unpressedDepth;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        height: widget.height,
        transform: Matrix4.translationValues(0, _isPressed ? (unpressedDepth - 1.5) : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.backgroundColor,
              Color.lerp(widget.backgroundColor, Colors.black, 0.35)!,
            ],
          ),
          border: Border.all(
            color: Colors.white.withAlpha(_isPressed ? 30 : 80),
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(150),
                    blurRadius: 2,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : [
                  // 3D Extrusion Bottom
                  BoxShadow(
                    color: Color.lerp(widget.backgroundColor, Colors.black, 0.75)!,
                    blurRadius: 0,
                    offset: Offset(0, depth),
                  ),
                  // Ambient Floor Drop Shadow
                  BoxShadow(
                    color: Colors.black.withAlpha(180),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                  // Top Specular Highlight
                  BoxShadow(
                    color: Colors.white.withAlpha(20),
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 26, color: widget.textColor),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
