import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/config/app_flavor.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/database/temposhot_database.dart';
import '../../../core/theme/ballistic_theme.dart';
import '../../../shared/widgets/ballistic_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../../shared/widgets/status_indicator_badge.dart';
import '../../../shared/widgets/tactile_pusher_button.dart';
import '../../../shared/widgets/upgrade_prompt_dialog.dart';
import '../domain/models/shot_string.dart';
import 'providers/history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _exportCsv(BuildContext context, List<ShotString> strings) async {
    final buffer = StringBuffer();
    buffer.writeln('StringId,DrillId,Timestamp,TotalTimeSec,FirstShotDelaySec,Notes');
    for (final s in strings) {
      buffer.writeln(
        '${s.id},${s.drillId},"${s.timestamp}",${s.totalTimeSec},${s.firstShotDelaySec},"${s.notes}"',
      );
    }
    await Share.share(buffer.toString(), subject: 'TempoShot Logbook Export.csv');
  }

  void _showStringDetails(BuildContext context, ShotString stringRecord) async {
    final tokens = BallisticTokens.of(context);
    final db = TempoShotDatabase.instance;
    final shots = await db.getShotsForString(stringRecord.id!);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
            border: Border.all(color: tokens.borderStrong, width: 2.0),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STRING #${stringRecord.id}',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: tokens.text,
                    ),
                  ),
                  Text(
                    '${stringRecord.totalTimeSec.toStringAsFixed(2)}s',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: tokens.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Recorded: ${stringRecord.timestamp.split('T')[0]} · First Shot: ${stringRecord.firstShotDelaySec.toStringAsFixed(2)}s',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontSize: 12,
                  color: tokens.textMuted,
                ),
              ),
              if (stringRecord.notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Notes: ${stringRecord.notes}',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: tokens.text,
                  ),
                ),
              ],
              const Divider(height: AppSpacing.xl),
              // Splits List
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: shots.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: tokens.border),
                  itemBuilder: (_, i) {
                    final s = shots[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#${s.shotNumber}', style: TextStyle(fontWeight: FontWeight.bold, color: tokens.text)),
                          Text('Split: ${s.splitTimeSec.toStringAsFixed(2)}s', style: TextStyle(color: tokens.text)),
                          Text('Total: ${s.cumulativeTimeSec.toStringAsFixed(2)}s', style: TextStyle(color: tokens.textMuted)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = BallisticTokens.of(context);
    final flavor = ref.watch(flavorConfigProvider);
    final stringsAsync = ref.watch(allStringsProvider);
    final countAsync = ref.watch(stringCountProvider);

    return ResponsiveScaffold(
      body: CustomScrollView(
        slivers: [
          // Nav Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: tokens.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: tokens.border, width: 1.5),
                        ),
                        child: Icon(Icons.arrow_back, color: tokens.text, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'RANGE LOGBOOK',
                      style: TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                        color: tokens.text,
                      ),
                    ),
                  ),
                  countAsync.when(
                    data: (count) {
                      final max = flavor.maxSavedStrings;
                      return StatusIndicatorBadge(
                        label: max != null ? '$count / $max' : '$count STRINGS',
                        dotColor: max != null && count >= max ? tokens.alert : tokens.success,
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          // Storage Limit Banner (Lite only when full)
          if (flavor.isLite)
            SliverToBoxAdapter(
              child: countAsync.maybeWhen(
                data: (count) {
                  final max = flavor.maxSavedStrings ?? 10;
                  if (count < max) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
                    child: BallisticCard(
                      surfaceColor: tokens.alert.withValues(alpha: 0.12),
                      borderColor: tokens.alert,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: tokens.alert, size: 24),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Lite storage full ($count/$max strings). Older runs will be replaced.',
                              style: TextStyle(
                                fontFamily: 'PublicSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.text,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => UpgradePromptDialog.show(context),
                            child: Text(
                              'GET PRO',
                              style: TextStyle(
                                fontFamily: 'PublicSans',
                                fontWeight: FontWeight.bold,
                                color: tokens.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          // Strings List
          stringsAsync.when(
            data: (strings) {
              if (strings.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: tokens.textMuted),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'NO SAVED STRINGS YET',
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                            color: tokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Run a live-fire drill and save your splits.',
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontSize: 13,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stringRecord = strings[index];
                      final dateStr = stringRecord.timestamp.split('T')[0];

                      return Dismissible(
                        key: ValueKey(stringRecord.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          color: tokens.alert,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          final db = TempoShotDatabase.instance;
                          await db.deleteString(stringRecord.id!);
                          ref.invalidate(allStringsProvider);
                          ref.invalidate(stringCountProvider);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: BallisticCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: InkWell(
                              onTap: () => _showStringDetails(context, stringRecord),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'STRING #${stringRecord.id}',
                                        style: TextStyle(
                                          fontFamily: 'PublicSans',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: tokens.text,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$dateStr · First: ${stringRecord.firstShotDelaySec.toStringAsFixed(2)}s',
                                        style: TextStyle(
                                          fontFamily: 'PublicSans',
                                          fontSize: 12,
                                          color: tokens.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${stringRecord.totalTimeSec.toStringAsFixed(2)}s',
                                        style: TextStyle(
                                          fontFamily: 'PublicSans',
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22,
                                          color: tokens.text,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Icon(Icons.chevron_right, size: 20, color: tokens.textMuted),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: strings.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error loading strings: $err')),
            ),
          ),
          // CSV Export Button for Pro
          if (flavor.isPro)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                child: TactilePusherButton(
                  label: 'EXPORT ALL AS CSV',
                  icon: Icons.download,
                  variant: PusherVariant.secondary,
                  onPressed: () async {
                    final strings = await ref.read(allStringsProvider.future);
                    if (context.mounted && strings.isNotEmpty) {
                      await _exportCsv(context, strings);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
