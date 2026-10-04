import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BacklitLcdDisplay3D extends StatelessWidget {
  final double timeSec;
  final int shotCount;
  final double lastSplitSec;
  final bool isArmed;
  final bool isRunning;

  const BacklitLcdDisplay3D({
    super.key,
    required this.timeSec,
    required this.shotCount,
    required this.lastSplitSec,
    this.isArmed = false,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormatted = timeSec.toStringAsFixed(2).padLeft(5, '0');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lcdBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.olive.withAlpha(120),
          width: 2.0,
        ),
        boxShadow: [
          // Inner Recessed Display Shadow
          BoxShadow(
            color: Colors.black.withAlpha(220),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Top Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isArmed
                              ? AppColors.blazeBright
                              : (isRunning ? AppColors.lcdGreenText : AppColors.olive),
                          boxShadow: [
                            if (isArmed || isRunning)
                              BoxShadow(
                                color: (isArmed ? AppColors.blazeBright : AppColors.lcdGreenText).withAlpha(180),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isArmed ? 'ARMED (STANDBY)' : (isRunning ? 'LIVE TIMER' : 'READY'),
                        style: TextStyle(
                          color: isArmed ? AppColors.blazeBright : AppColors.paperMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SHOTS: $shotCount',
                    style: const TextStyle(
                      color: AppColors.paper,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Giant 80sp 3D Chrono Digits
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  timeFormatted,
                  style: TextStyle(
                    color: isArmed ? AppColors.blazeBright : AppColors.paper,
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                    fontFamily: 'monospace',
                    shadows: [
                      Shadow(
                        color: (isArmed ? AppColors.blazeBright : Colors.white).withAlpha(60),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Bottom Split Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SPLIT: ${lastSplitSec > 0 ? '+${lastSplitSec.toStringAsFixed(2)}s' : '--'}',
                    style: const TextStyle(
                      color: AppColors.lcdAmberText,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Text(
                    '100% OFFLINE DSP',
                    style: TextStyle(
                      color: AppColors.oliveLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Glass Glare Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GlassSpecularGlarePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSpecularGlarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glarePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.15, size.height)
      ..lineTo(0, size.height)
      ..close();

    final glarePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withAlpha(18),
          Colors.white.withAlpha(4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(glarePath, glarePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
