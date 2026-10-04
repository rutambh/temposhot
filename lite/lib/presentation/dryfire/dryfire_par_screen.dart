import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/3d/backlit_lcd_display_3d.dart';
import '../../core/widgets/3d/tactile_pusher_button_3d.dart';
import '../../core/widgets/3d/tactile_timer_chassis_3d.dart';

class DryFireParScreen extends StatefulWidget {
  const DryFireParScreen({super.key});

  @override
  State<DryFireParScreen> createState() => _DryFireParScreenState();
}

class _DryFireParScreenState extends State<DryFireParScreen> {
  double _parTimeSec = 1.80;
  bool _isArmed = false;
  bool _isRunning = false;
  double _elapsedTimeSec = 0.0;
  Timer? _parTimer;
  Timer? _delayTimer;

  @override
  void dispose() {
    _parTimer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  void _startParSequence() {
    setState(() {
      _isArmed = true;
      _isRunning = false;
      _elapsedTimeSec = 0.0;
    });

    _delayTimer?.cancel();
    _delayTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _isArmed = false;
        _isRunning = true;
      });

      final startTime = DateTime.now();
      _parTimer?.cancel();
      _parTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
        final elapsed = DateTime.now().difference(startTime).inMicroseconds / 1000000.0;
        if (elapsed >= _parTimeSec) {
          timer.cancel();
          HapticFeedback.heavyImpact();
          setState(() {
            _isRunning = false;
            _elapsedTimeSec = _parTimeSec;
          });
        } else {
          setState(() {
            _elapsedTimeSec = elapsed;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Dry-Fire Par Timer', style: TextStyle(color: AppColors.paper)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 3D Chassis Display
              TactileTimerChassis3D(
                child: BacklitLcdDisplay3D(
                  timeSec: _elapsedTimeSec,
                  shotCount: _isRunning ? 1 : 0,
                  lastSplitSec: _parTimeSec,
                  isArmed: _isArmed,
                  isRunning: _isRunning,
                ),
              ),

              const SizedBox(height: 24),

              // Par Time Selector Slider
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.blackCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.olive.withAlpha(70)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Target Par Time',
                          style: TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${_parTimeSec.toStringAsFixed(2)}s',
                          style: const TextStyle(color: AppColors.blazeBright, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.blaze,
                        inactiveTrackColor: AppColors.blackSurface,
                        thumbColor: AppColors.blazeBright,
                      ),
                      child: Slider(
                        value: _parTimeSec,
                        min: 0.80,
                        max: 4.00,
                        divisions: 32,
                        onChanged: (val) => setState(() => _parTimeSec = val),
                      ),
                    ),
                    const Text(
                      'Start Beep -> Par Beep interval for draw & reload dry-fire reps.',
                      style: TextStyle(color: AppColors.paperMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Start Par Sequence Pusher
              TactilePusherButton3D(
                onPressed: _startParSequence,
                label: _isArmed ? 'ARMED • STANDBY' : (_isRunning ? 'RUNNING PAR...' : 'START PAR BEEP'),
                icon: Icons.play_arrow,
                backgroundColor: _isArmed ? AppColors.blazeDim : AppColors.blaze,
                height: 68,
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
