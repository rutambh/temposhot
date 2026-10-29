import 'package:flutter/material.dart';
import '../../theme/field_notebook_theme.dart';

/// The readout panel: a hairline-bordered inset on raised paper, with the
/// serif Newsreader digits the Field Notebook style calls for.
///
/// Class name kept from the old skeuomorphic build so the call sites and
/// their test do not churn; the treatment itself is now paper, not glass.
class BacklitLcdDisplay3D extends StatelessWidget {
  final double timeSec;
  final int shotCount;
  final double lastSplitSec;
  final bool isArmed;
  final bool isRunning;

  /// The dry-fire par timer has no shot count, so it can hide the counter
  /// instead of showing a meaningless zero.
  final bool showShotCounter;

  /// Replaces the "SPLIT: …" footer when set. The par timer uses this to show
  /// the target par time instead of a split it does not measure.
  final String? footerText;

  const BacklitLcdDisplay3D({
    super.key,
    required this.timeSec,
    required this.shotCount,
    required this.lastSplitSec,
    this.isArmed = false,
    this.isRunning = false,
    this.showShotCounter = true,
    this.footerText,
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
          // Status line: what the timer is doing, written as a field label,
          // with the shot count as a compact counter chip on the right.
          Row(
            children: [
              Expanded(
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
              if (showShotCounter) ...[
                const SizedBox(width: 10),
                _ShotCounter(count: shotCount, tokens: tokens),
              ],
            ],
          ),

          const SizedBox(height: 6),
          Divider(color: tokens.border, height: 13),

          // The number. FittedBox keeps it on one line at 320dp and below.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              timeFormatted,
              style: tokens.readout(
                color: stateColor,
                size: 72,
                weight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 6),
          Divider(color: tokens.border, height: 13),

          Row(
            children: [
              Flexible(
                child: Text(
                  footerText ??
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

/// A small instrument badge rather than a sentence: label on the left, big
/// tabular number on the right, with a brief scale/fade when it changes.
class _ShotCounter extends StatelessWidget {
  const _ShotCounter({required this.count, required this.tokens});

  final int count;
  final FieldNotebookTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tokens.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: tokens.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'SHOTS',
            style: tokens.label(
              color: tokens.textMuted,
              size: 9,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 7),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder:
                (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
            child: Text(
              '$count',
              key: ValueKey(count),
              style: tokens.readout(
                color: tokens.primary,
                size: 22,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
