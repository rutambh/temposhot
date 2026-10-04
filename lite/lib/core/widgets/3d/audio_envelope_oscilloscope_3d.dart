import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/field_notebook_theme.dart';

/// Live input envelope, drawn the way a seismograph trace is drawn on paper:
/// ink blue trace, olive threshold rule, faint dot-grid ruling behind it.
class AudioEnvelopeOscilloscope3D extends StatelessWidget {
  final List<double> waveSamples;
  final double threshold;
  final double height;

  const AudioEnvelopeOscilloscope3D({
    super.key,
    required this.waveSamples,
    required this.threshold,
    this.height = 110.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: tokens.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _OscilloscopePainter(
          samples: waveSamples,
          threshold: threshold,
          grid: tokens.grid,
          trace: tokens.primary,
          thresholdColor: tokens.accent,
        ),
      ),
    );
  }
}

class _OscilloscopePainter extends CustomPainter {
  final List<double> samples;
  final double threshold;
  final Color grid;
  final Color trace;
  final Color thresholdColor;

  _OscilloscopePainter({
    required this.samples,
    required this.threshold,
    required this.grid,
    required this.trace,
    required this.thresholdColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ruling. Only horizontals, so it reads as a chart and not as graph paper.
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;

    for (double y = size.height * 0.25; y < size.height; y += size.height * 0.25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Sensitivity threshold rule.
    final threshY = size.height * (1.0 - threshold.clamp(0.1, 0.95));
    final threshPaint = Paint()
      ..color = thresholdColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, threshY), Offset(size.width, threshY), threshPaint);

    // 3. Audio envelope.
    if (samples.isNotEmpty) {
      final wavePath = Path();
      final dx = size.width / math.max(samples.length - 1, 1);

      for (int i = 0; i < samples.length; i++) {
        final val = samples[i].clamp(0.0, 1.0);
        final px = i * dx;
        final py = size.height * (1.0 - val);

        if (i == 0) {
          wavePath.moveTo(px, py);
        } else {
          wavePath.lineTo(px, py);
        }
      }

      final wavePaint = Paint()
        ..color = trace
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(wavePath, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OscilloscopePainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.threshold != threshold ||
        oldDelegate.trace != trace;
  }
}