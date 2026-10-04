import 'package:flutter/material.dart';
import '../../theme/field_notebook_theme.dart';

/// The readout panel: a hairline-bordered inset on raised paper, with the
/// serif Newsreader digits the Field Notebook style calls for.
///
/// Class name kept from the old skeuomorphic build so the two call sites and
/// their test do not churn; the treatment itself is now paper, not glass.
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
    final tokens = FieldNotebookTheme.of(context);
    final timeFormatted = timeSec.toStringAsFixed(2).padLeft(5, '0');
    // One colour per state, so "armed" reads instantly at a glance.
    final stateColor =
        isArmed ? tokens.accent : (isRunning ? tokens.success : tokens.primary);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: tokens.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          // Status line: what the timer is doing, written as a field label.
          Row(
            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: stateColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isArmed
                            ? 'ARMED (STANDBY)'
                            : (isRunning ? 'LIVE TIMER' : 'READY'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tokens.label(color: stateColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'SHOTS: $shotCount',
                    style: tokens.readout(
                      color: tokens.text,
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Divider(color: tokens.border, height: 13),

          // The number. FittedBox keeps it on one line at 320dp and below.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              timeFormatted,
              style: tokens.readout(color: stateColor, size: 72, weight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 6),
          Divider(color: tokens.border, height: 13),

          Row(
            children: [
              Flexible(
                child: Text(
                  'SPLIT: ${lastSplitSec > 0 ? '+${lastSplitSec.toStringAsFixed(2)}s' : '--'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.readout(
                    color: tokens.warning,
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '100% OFFLINE DSP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: tokens.label(color: tokens.textMuted, size: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}