import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/3d/backlit_lcd_display_3d.dart';
import '../../core/widgets/3d/tactile_pusher_button_3d.dart';
import '../../core/widgets/3d/tactile_timer_chassis_3d.dart';
import '../dryfire/dryfire_par_screen.dart';
import '../history/history_screen.dart';
import '../live/live_timer_screen.dart';
import '../paywall/pro_paywall_screen.dart';
import '../providers/app_providers.dart';
import '../safety/sports_disclaimer_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  double _sensitivity = AppConstants.defaultSensitivityThreshold;

  @override
  Widget build(BuildContext context) {
    final stringCountAsync = ref.watch(stringCountProvider);
    final stringsAsync = ref.watch(allStringsProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blaze,
              ),
            ),
            const SizedBox(width: 8),
            const Text('TempoShot', style: TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.paper),
            tooltip: 'String History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.paper),
            tooltip: 'Safety Notice',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => SportsDisclaimerDialog(onAccept: () => Navigator.of(context).pop()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 3D Skeuomorphic Chrono Timer Chassis Hero
            TactileTimerChassis3D(
              child: Column(
                children: [
                  const BacklitLcdDisplay3D(
                    timeSec: 0.0,
                    shotCount: 0,
                    lastSplitSec: 0.0,
                    isArmed: false,
                    isRunning: false,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.oliveLight, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'PRACTICE READY • USPSA / IDPA',
                        style: TextStyle(
                          color: AppColors.oliveLight.withAlpha(200),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Big 3D Tactile Pushers Row
            TactilePusherButton3D(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LiveTimerScreen(sensitivity: _sensitivity),
                  ),
                );
              },
              label: 'START LIVE-FIRE TIMER',
              icon: Icons.timer,
              backgroundColor: AppColors.blaze,
              textColor: Colors.white,
              height: 66,
            ),

            const SizedBox(height: 14),

            TactilePusherButton3D(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DryFireParScreen()),
                );
              },
              label: 'START DRY-FIRE PAR',
              icon: Icons.flash_on,
              backgroundColor: AppColors.olive,
              textColor: AppColors.paper,
              height: 60,
            ),

            const SizedBox(height: 20),

            // Sensitivity Threshold Slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blackCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.olive.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mic Sensitivity Threshold',
                        style: TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${(_sensitivity * 100).toInt()}%',
                        style: const TextStyle(color: AppColors.blazeBright, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.blaze,
                      inactiveTrackColor: AppColors.blackSurface,
                      thumbColor: AppColors.blazeBright,
                    ),
                    child: Slider(
                      value: _sensitivity,
                      min: 0.20,
                      max: 0.95,
                      divisions: 15,
                      onChanged: (val) => setState(() => _sensitivity = val),
                    ),
                  ),
                  const Text(
                    'Adjust to filter out brass echoes or indoor range neighbor gunshots.',
                    style: TextStyle(color: AppColors.paperMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Strings & Lite Gating Counter
            stringCountAsync.when(
              data: (count) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blackCardHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.olive.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storage, color: AppColors.blaze, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lite Storage: $count / ${AppConstants.liteMaxStrings} Strings',
                            style: const TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const Text(
                            'Upgrade to Pro for unlimited drill strings & PDF export.',
                            style: TextStyle(color: AppColors.paperMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
                        );
                      },
                      child: const Text('Pro', style: TextStyle(color: AppColors.blazeBright, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
