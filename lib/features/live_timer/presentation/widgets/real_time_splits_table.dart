import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/ballistic_theme.dart';
import '../../../../shared/widgets/ballistic_card.dart';
import '../../../history/domain/models/shot_record.dart';

/// Live splits table rendering shot breaks, split times, and cumulative elapsed times.
class RealTimeSplitsTable extends StatelessWidget {
  final List<ShotRecord> shots;
  final Function(int index)? onDeleteShot;

  const RealTimeSplitsTable({
    super.key,
    required this.shots,
    this.onDeleteShot,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);

    return BallisticCard(
      surfaceColor: tokens.surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: tokens.surfaceSub,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg - 1.5),
                topRight: Radius.circular(AppSpacing.radiusLg - 1.5),
              ),
              border: Border(
                bottom: BorderSide(color: tokens.border, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    'SHOT',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.0,
                      color: tokens.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'SPLIT TIME',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.0,
                      color: tokens.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CUMULATIVE',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.0,
                      color: tokens.textMuted,
                    ),
                  ),
                ),
                if (onDeleteShot != null)
                  const SizedBox(width: 32),
              ],
            ),
          ),
          // Empty State or Rows
          if (shots.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'AWAITING SHOT BREAKS...',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: tokens.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shots.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: tokens.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final shot = shots[index];
                final isFastest = shots.length > 1 &&
                    shot.shotNumber > 1 &&
                    shot.splitTimeSec ==
                        shots
                            .skip(1)
                            .map((s) => s.splitTimeSec)
                            .reduce((a, b) => a < b ? a : b);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          '#${shot.shotNumber.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: tokens.text,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${shot.splitTimeSec.toStringAsFixed(2)}s',
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isFastest ? tokens.primary : tokens.text,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${shot.cumulativeTimeSec.toStringAsFixed(2)}s',
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: tokens.text,
                          ),
                        ),
                      ),
                      if (onDeleteShot != null)
                        Semantics(
                          button: true,
                          label: 'Delete shot ${shot.shotNumber}',
                          child: InkWell(
                            onTap: () => onDeleteShot!(index),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: tokens.textMuted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
