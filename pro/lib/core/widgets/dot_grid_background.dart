import 'package:flutter/material.dart';

import '../theme/field_notebook_theme.dart';

/// Dot-grid notebook paper, painted behind the app shell.
///
/// This paints the paper *and* the dots. Painting only the dots leaves the
/// sheet transparent, and because every screen keeps its Scaffold transparent
/// so this can show through, the app then falls back to the platform window
/// background — white on a light system, near-black on a dark one — and the
/// cream paper never appears at all.
///
/// RepaintBoundary matters: the live timer repaints at 30 fps and this
/// painter must not be redrawn with it.
class DotGridBackground extends StatelessWidget {
  const DotGridBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    return RepaintBoundary(
      child: CustomPaint(
        painter: DotGridPainter(
          background: tokens.background,
          color: tokens.grid,
          pitch: tokens.gridPitch,
        ),
        child: child,
      ),
    );
  }
}

/// Public so a test can paint it directly and assert the paper is actually
/// laid down, rather than trusting that it looks right.
class DotGridPainter extends CustomPainter {
  DotGridPainter({
    required this.background,
    required this.color,
    required this.pitch,
  });

  final Color background;
  final Color color;
  final double pitch;

  static const double _dotRadius = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    // The sheet first. Everything else is drawn on top of it.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = background,
    );

    if (pitch <= 0) return;
    final paint = Paint()..color = color;
    // Start half a pitch in so dots sit on the grid, not on its edges.
    for (var y = pitch / 2; y < size.height; y += pitch) {
      for (var x = pitch / 2; x < size.width; x += pitch) {
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.color != color ||
      oldDelegate.pitch != pitch;
}
