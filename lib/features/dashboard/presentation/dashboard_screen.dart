import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_flavor.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/ballistic_theme.dart';
import '../../../shared/widgets/ballistic_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../../shared/widgets/status_indicator_badge.dart';
import '../../../shared/widgets/tactile_pusher_button.dart';
import '../../../shared/widgets/theme_mode_toggle_button.dart';
import '../../dry_fire/presentation/dry_fire_par_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../history/presentation/providers/history_providers.dart';
import '../../live_timer/presentation/live_timer_screen.dart';
import '../../paywall/presentation/pro_paywall_screen.dart';
import '../../safety/presentation/sports_disclaimer_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final bool showStartupDisclaimer;

  const DashboardScreen({
    super.key,
    this.showStartupDisclaimer = true,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.showStartupDisclaimer) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final accepted = await SportsDisclaimerDialog.isAccepted();
        if (!accepted && mounted) {
          SportsDisclaimerDialog.show(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);
    final flavor = ref.watch(flavorConfigProvider);
    final stringsAsync = ref.watch(allStringsProvider);
    final countAsync = ref.watch(stringCountProvider);

    return ResponsiveScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top App Bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            flavor.appName.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: 1.5,
                              color: tokens.text,
                            ),
                          ),
                          StatusIndicatorBadge(
                            label: flavor.isPro ? 'PRO' : 'LITE',
                            dotColor: flavor.isPro ? tokens.primary : tokens.textMuted,
                          ),
                        ],
                      ),
                      Text(
                        'ACOUSTIC RANGE TIMER & DRY-FIRE PAR',
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Safety Info Button
                Semantics(
                  button: true,
                  label: 'Safety notice',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    onTap: () => SportsDisclaimerDialog.show(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: tokens.border, width: 1.5),
                      ),
                      child: Icon(Icons.shield_outlined, color: tokens.text, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Theme Toggle
                const ThemeModeToggleButton(),
                const SizedBox(width: AppSpacing.sm),
                // History Button
                Semantics(
                  button: true,
                  label: 'Logbook history',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: tokens.border, width: 1.5),
                      ),
                      child: Icon(Icons.history, color: tokens.text, size: 22),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Lite Edition Banner / Pro Status
            if (flavor.isLite)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: BallisticCard(
                  surfaceColor: tokens.surfaceSub,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, color: tokens.primary, size: 24),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: countAsync.maybeWhen(
                          data: (cnt) => Text(
                            'Lite Logbook: $cnt / 10 strings stored',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: tokens.text,
                            ),
                          ),
                          orElse: () => Text(
                            'Lite Edition · 10 Strings Cap',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: tokens.text,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
                          );
                        },
                        child: Text(
                          'GET PRO',
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: tokens.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Last String Recap Card
            Text(
              'RECENT DRILL TELEMETRY',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            stringsAsync.when(
              data: (strings) {
                if (strings.isEmpty) {
                  return BallisticCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.timer_outlined, size: 36, color: tokens.textMuted),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'NO STRINGS RECORDED YET',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.0,
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final last = strings.first;
                return BallisticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BILL DRILL (6 SHOTS)',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                              color: tokens.text,
                            ),
                          ),
                          Text(
                            last.timestamp.split('T')[0],
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontSize: 12,
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL TIME',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: tokens.textMuted,
                                ),
                              ),
                              Text(
                                '${last.totalTimeSec.toStringAsFixed(2)}s',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  fontWeight: FontWeight.w900,
                                  fontSize: 40,
                                  color: tokens.text,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'FIRST DRAW',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: tokens.textMuted,
                                ),
                              ),
                              Text(
                                '${last.firstShotDelaySec.toStringAsFixed(2)}s',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: tokens.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const BallisticCard(
                child: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Primary Action: Start Live-Fire Timer
            TactilePusherButton(
              label: 'START LIVE-FIRE TIMER',
              icon: Icons.mic,
              variant: PusherVariant.primary,
              height: 68,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveTimerScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // Secondary Action: Start Dry-Fire Par
            TactilePusherButton(
              label: 'START DRY-FIRE PAR',
              icon: Icons.speed,
              variant: PusherVariant.secondary,
              height: 54,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DryFireParScreen()),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Settings & Pro Link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
                  );
                },
                icon: Icon(
                  flavor.isPro ? Icons.star : Icons.workspace_premium,
                  size: 16,
                  color: tokens.textMuted,
                ),
                label: Text(
                  flavor.isPro ? 'TEMPOSHOT PRO · LIFETIME' : 'UPGRADE TO PRO · \$14.99',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                    color: tokens.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
