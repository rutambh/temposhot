import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lcdBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.olive.withAlpha(90), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(180),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _OscilloscopePainter(
          samples: waveSamples,
          threshold: threshold,
        ),
      ),
    );
  }
}

class _OscilloscopePainter extends CustomPainter {
  final List<double> samples;
  final double threshold;

  _OscilloscopePainter({
    required this.samples,
    required this.threshold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid Background
    final gridPaint = Paint()
      ..color = AppColors.olive.withAlpha(35)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Sensitivity Threshold Line
    final threshY = size.height * (1.0 - threshold.clamp(0.1, 0.95));
    final threshPaint = Paint()
      ..color = AppColors.blazeBright.withAlpha(180)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, threshY), Offset(size.width, threshY), threshPaint);

    // 3. Audio Waveform
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

      final waveGlowPaint = Paint()
        ..color = AppColors.lcdGreenText.withAlpha(100)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final waveLinePaint = Paint()
        ..color = AppColors.lcdGreenText
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(wavePath, waveGlowPaint);
      canvas.drawPath(wavePath, waveLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OscilloscopePainter oldDelegate) {
    return oldDelegate.samples != samples || oldDelegate.threshold != threshold;
  }
}
