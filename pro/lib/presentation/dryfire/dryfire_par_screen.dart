import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/field_notebook_theme.dart';
import '../../core/widgets/3d/backlit_lcd_display_3d.dart';
import '../../core/widgets/paper_card.dart';
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
    final tokens = FieldNotebookTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Dry-fire par timer',
          style: tokens.body(color: tokens.text, size: 17, weight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // The timer, in its chassis.
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
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TARGET PAR TIME',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.label(color: tokens.text),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_parTimeSec.toStringAsFixed(2)}s',
                          style: tokens.readout(
                              color: tokens.primary, size: 19),
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
                        value: _parTimeSec,
                        min: 0.80,
                        max: 4.00,
                        divisions: 32,
                        onChanged: (val) => setState(() => _parTimeSec = val),
                      ),
                    ),
                    Text(
                      'The gap between the start beep and the par beep, for '
                      'draw-and-reload dry-fire repetitions.',
                      style: tokens.body(color: tokens.textMuted, size: 12),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Start Par Sequence Pusher
              TactilePusherButton3D(
                onPressed: _startParSequence,
                label: _isArmed
                    ? 'ARMED — STANDBY'
                    : (_isRunning ? 'RUNNING PAR…' : 'START PAR BEEP'),
                icon: Icons.play_arrow,
                backgroundColor: _isArmed ? tokens.accent : tokens.primary,
                textColor: tokens.onPrimary,
                height: 62,
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
