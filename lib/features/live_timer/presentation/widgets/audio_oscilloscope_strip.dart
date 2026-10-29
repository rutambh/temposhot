import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/ballistic_theme.dart';

/// Real-time audio energy oscilloscope rendering 40 vertical energy bars
/// with gunshot peak threshold indication.
class AudioOscilloscopeStrip extends StatelessWidget {
  final List<double> waveBuffer;
  final double threshold;
  final double height;

  const AudioOscilloscopeStrip({
    super.key,
    required this.waveBuffer,
    this.threshold = 0.65,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: tokens.oscilloscopeBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: tokens.border, width: 1.0),
      ),
      child: CustomPaint(
        painter: _OscilloscopePainter(
          samples: waveBuffer,
          threshold: threshold,
          barColor: tokens.isDark ? const Color(0xFF3E4740) : const Color(0xFF8C9484),
          peakColor: tokens.primary,
          baselineColor: tokens.borderStrong,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _OscilloscopePainter extends CustomPainter {
  final List<double> samples;
  final double threshold;
  final Color barColor;
  final Color peakColor;
  final Color baselineColor;

  _OscilloscopePainter({
    required this.samples,
    required this.threshold,
    required this.barColor,
    required this.peakColor,
    required this.baselineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final barPaint = Paint()..style = PaintingStyle.fill;
    final baselinePaint = Paint()
      ..color = baselineColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), baselinePaint);

    final totalBars = samples.length;
    final barSpacing = size.width / totalBars;
    final barWidth = (barSpacing * 0.7).clamp(2.0, 6.0);

    for (var i = 0; i < totalBars; i++) {
      final amp = samples[i].clamp(0.0, 1.0);
      final isPeak = amp >= threshold;
      barPaint.color = isPeak ? peakColor : barColor;

      final barH = (amp * (size.height * 0.88)).clamp(3.0, size.height);
      final x = i * barSpacing + (barSpacing - barWidth) / 2;
      final y = centerY - barH / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barH),
          const Radius.circular(2.0),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_OscilloscopePainter oldDelegate) => true;
}
