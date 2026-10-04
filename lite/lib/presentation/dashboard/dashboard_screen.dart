import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/field_notebook_theme.dart';
import '../../core/widgets/3d/backlit_lcd_display_3d.dart';
import '../../core/widgets/3d/tactile_pusher_button_3d.dart';
import '../../core/widgets/3d/tactile_timer_chassis_3d.dart';
import '../../core/widgets/paper_card.dart';
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
    final tokens = FieldNotebookTheme.of(context);
    final stringCountAsync = ref.watch(stringCountProvider);

    return Scaffold(
      // Transparent so the app shell's dot-grid paper reads through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.primary,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'TempoShot',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: tokens.text),
            tooltip: 'String History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: tokens.text),
            tooltip: 'Safety Notice',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => SportsDisclaimerDialog(
                    onAccept: () => Navigator.of(context).pop()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            // The timer itself: chassis, readout panel, envelope trace.
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: tokens.accent, size: 15),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'PRACTICE READY — USPSA / IDPA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tokens.label(color: tokens.accent, size: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

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
              backgroundColor: tokens.primary,
              textColor: tokens.onPrimary,
              height: 62,
            ),

            const SizedBox(height: 12),

            TactilePusherButton3D(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DryFireParScreen()),
                );
              },
              label: 'START DRY-FIRE PAR',
              icon: Icons.flash_on,
              backgroundColor: tokens.accent,
              textColor: tokens.onPrimary,
              height: 56,
              fontSize: 15,
            ),

            const SizedBox(height: 18),

            PaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MIC SENSITIVITY THRESHOLD',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tokens.label(color: tokens.text),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_sensitivity * 100).toInt()}%',
                        style: tokens.readout(
                          color: tokens.primary,
                          size: 17,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: tokens.primary,
                      inactiveTrackColor: tokens.grid,
                      thumbColor: tokens.primary,
                    ),
                    child: Slider(
                      value: _sensitivity,
                      min: 0.20,
                      max: 0.95,
                      divisions: 15,
                      onChanged: (val) => setState(() => _sensitivity = val),
                    ),
                  ),
                  Text(
                    'Raise this to filter brass echoes and neighbouring '
                    'range gunfire. Lower it if quiet strings are not being '
                    'detected.',
                    style: tokens.body(color: tokens.textMuted, size: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            stringCountAsync.when(
              data: (count) => PaperCard(
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                child: Row(
                  children: [
                    Icon(Icons.storage, color: tokens.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lite storage: $count / ${AppConstants.liteMaxStrings} strings',
                            maxLines: 2,
                            style: tokens.body(
                              color: tokens.text,
                              size: 13,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pro adds unlimited strings and PDF export.',
                            style: tokens.body(color: tokens.textMuted, size: 12),
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
                      child: Text(
                        'Pro',
                        style: TextStyle(
                          color: tokens.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}