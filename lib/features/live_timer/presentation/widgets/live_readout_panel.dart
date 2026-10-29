import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/ballistic_theme.dart';
import '../../../../shared/widgets/ballistic_card.dart';
import '../../../../shared/widgets/status_indicator_badge.dart';

/// Master telemetry timing display for the live shot timer.
class LiveReadoutPanel extends StatelessWidget {
  final double currentTimeSec;
  final bool isArmed;
  final bool isRunning;
  final double firstShotSec;
  final double lastSplitSec;
  final int shotCount;
  final int maxShots;

  const LiveReadoutPanel({
    super.key,
    required this.currentTimeSec,
    required this.isArmed,
    required this.isRunning,
    required this.firstShotSec,
    required this.lastSplitSec,
    required this.shotCount,
    this.maxShots = 6,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);
    final formattedTime = currentTimeSec.toStringAsFixed(2).padLeft(5, '0');

    String statusText;
    Color statusColor;

    if (isArmed) {
      statusText = 'ARMED · STAND BY';
      statusColor = tokens.primary;
    } else if (isRunning) {
      statusText = 'HOT RANGE · RECORDING';
      statusColor = tokens.primary;
    } else {
      statusText = 'TIMER STOPPED';
      statusColor = tokens.borderStrong;
    }

    return BallisticCard(
      surfaceColor: tokens.surface,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Status Bar inside chassis
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              StatusIndicatorBadge(
                label: statusText,
                dotColor: statusColor,
                isPulsing: isRunning || isArmed,
              ),
              Text(
                'DELAY: 1-4s',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Massive Live Digits Readout
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formattedTime,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w900,
                fontSize: 76,
                letterSpacing: -1.0,
                color: tokens.text,
              ),
            ),
          ),
          Text(
            'TOTAL SECONDS',
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Lower Horizon Metric Pills
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  tokens,
                  label: 'FIRST SHOT',
                  value: firstShotSec > 0
                      ? '${firstShotSec.toStringAsFixed(2)}s'
                      : '--',
                  highlight: false,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricItem(
                  tokens,
                  label: 'LAST SPLIT',
                  value: lastSplitSec > 0
                      ? '${lastSplitSec.toStringAsFixed(2)}s'
                      : '--',
                  highlight: lastSplitSec > 0,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricItem(
                  tokens,
                  label: 'SHOT COUNT',
                  value: '$shotCount',
                  highlight: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BallisticTokens tokens, {
    required String label,
    required String value,
    required bool highlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceSub,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: highlight ? tokens.primary : tokens.border,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: tokens.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontFeatures: const [FontFeature.tabularFigures()],
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: highlight ? tokens.primary : tokens.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
