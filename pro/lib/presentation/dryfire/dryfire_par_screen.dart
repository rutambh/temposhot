import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/cue_player.dart';
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
  /// Fixed lead-in after the start button. Long enough to get set, short
  /// enough that the screen never feels stuck.
  static const double _armLeadInSec = 2.0;

  double _parTimeSec = 1.80;
  bool _isArmed = false;
  bool _isRunning = false;
  bool _hasFinished = false;
  double _elapsedTimeSec = 0.0;
  double _armRemainingSec = _armLeadInSec;

  Timer? _parTimer;
  Timer? _armTimer;
  final CuePlayer _cuePlayer = CuePlayer();

  bool get _isBusy => _isArmed || _isRunning;

  double get _progress {
    if (_isArmed) {
      return ((_armLeadInSec - _armRemainingSec) / _armLeadInSec)
          .clamp(0.0, 1.0)
          .toDouble();
    }
    if (_isRunning) {
      return (_elapsedTimeSec / _parTimeSec).clamp(0.0, 1.0).toDouble();
    }
    return _hasFinished ? 1.0 : 0.0;
  }

  String get _statusHeadline {
    if (_isArmed) return 'ARMING — ${_armRemainingSec.toStringAsFixed(1)}s';
    if (_isRunning) return 'REP RUNNING';
    if (_hasFinished) return 'PAR REACHED';
    return 'READY';
  }

  String get _statusDetail {
    if (_isArmed) {
      return 'Stand by. The start cue is coming.';
    }
    if (_isRunning) {
      return 'Beat the par. Finish the rep before '
          '${_parTimeSec.toStringAsFixed(2)}s.';
    }
    if (_hasFinished) {
      return 'The par cue ends the rep at ${_parTimeSec.toStringAsFixed(2)}s. '
          'That stop is the target, not a failure. Run another rep when ready.';
    }
    return 'Set your target par time, then start. This mode is a countdown '
        'par timer; it does not use the microphone.';
  }

  String get _buttonLabel {
    if (_isArmed) return 'ARMING — ${_armRemainingSec.toStringAsFixed(1)}s';
    if (_isRunning) {
      final left = (_parTimeSec - _elapsedTimeSec).clamp(0.0, _parTimeSec);
      return 'RUNNING — ${left.toStringAsFixed(2)}s LEFT';
    }
    if (_hasFinished) return 'RUN ANOTHER REP';
    return 'START PAR SEQUENCE';
  }

  @override
  void dispose() {
    _parTimer?.cancel();
    _armTimer?.cancel();
    unawaited(_cuePlayer.dispose());
    super.dispose();
  }

  void _startParSequence() {
    _cancelTimers();
    setState(() {
      _isArmed = true;
      _isRunning = false;
      _hasFinished = false;
      _elapsedTimeSec = 0.0;
      _armRemainingSec = _armLeadInSec;
    });

    unawaited(HapticFeedback.selectionClick());
    final armedAt = DateTime.now();
    _armTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final elapsed =
          DateTime.now().difference(armedAt).inMicroseconds / 1000000.0;
      final remaining = _armLeadInSec - elapsed;
      if (remaining <= 0) {
        timer.cancel();
        _beginRep();
      } else if (mounted) {
        setState(() => _armRemainingSec = remaining);
      }
    });
  }

  void _beginRep() {
    if (!mounted) return;
    unawaited(HapticFeedback.heavyImpact());
    unawaited(_cuePlayer.beep());
    setState(() {
      _isArmed = false;
      _isRunning = true;
      _hasFinished = false;
      _elapsedTimeSec = 0.0;
    });

    final startTime = DateTime.now();
    _parTimer?.cancel();
    _parTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      final elapsed =
          DateTime.now().difference(startTime).inMicroseconds / 1000000.0;
      if (elapsed >= _parTimeSec) {
        timer.cancel();
        _finishRep();
      } else if (mounted) {
        setState(() => _elapsedTimeSec = elapsed);
      }
    });
  }

  void _finishRep() {
    if (!mounted) return;
    unawaited(HapticFeedback.heavyImpact());
    unawaited(_cuePlayer.beep());
    setState(() {
      _isRunning = false;
      _hasFinished = true;
      _elapsedTimeSec = _parTimeSec;
    });
  }

  void _cancelTimers() {
    _parTimer?.cancel();
    _parTimer = null;
    _armTimer?.cancel();
    _armTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    final statusColor =
        _hasFinished
            ? tokens.success
            : (_isRunning ? tokens.primary : tokens.accent);
    final statusIcon =
        _hasFinished
            ? Icons.check_circle_outline
            : (_isRunning ? Icons.timer_outlined : Icons.bolt_outlined);

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
          style: tokens.body(
            color: tokens.text,
            size: 17,
            weight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            PaperCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: tokens.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WHAT IS DRY FIRE?',
                        style: tokens.label(color: tokens.text, size: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dry fire is practice with an empty, verified-unloaded '
                    'firearm: draw, reload, aim, and press the trigger without '
                    'live ammunition. TempoShot gives a start cue, then a par '
                    'cue at your target time. Finish the rep before the par cue.',
                    style: tokens.body(
                      color: tokens.textMuted,
                      size: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dry-fire only with a safe backstop, no ammunition in the '
                    'room, and the four universal safety rules in force.',
                    style: tokens.body(
                      color: tokens.accent,
                      size: 11.5,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            TactileTimerChassis3D(
              child: BacklitLcdDisplay3D(
                timeSec: _elapsedTimeSec,
                shotCount: 0,
                lastSplitSec: 0,
                isArmed: _isArmed,
                isRunning: _isRunning,
                showShotCounter: false,
                footerText: 'PAR: ${_parTimeSec.toStringAsFixed(2)}s',
              ),
            ),

            const SizedBox(height: 12),

            // The status card explains what the timer is doing and why it
            // stops at par time, so the stop never reads as a crash.
            PaperCard(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 19),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusHeadline,
                          style: tokens.label(color: statusColor, size: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: tokens.grid,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusDetail,
                    style: tokens.body(color: tokens.textMuted, size: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

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
                        style: tokens.readout(color: tokens.primary, size: 19),
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
                      onChanged:
                          _isBusy
                              ? null
                              : (val) {
                                setState(() {
                                  _parTimeSec = val;
                                  if (!_isBusy) {
                                    _hasFinished = false;
                                    _elapsedTimeSec = 0.0;
                                  }
                                });
                              },
                    ),
                  ),
                  Text(
                    'The gap between the start cue and the par cue, for '
                    'draw-and-reload dry-fire repetitions.',
                    style: tokens.body(color: tokens.textMuted, size: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            TactilePusherButton3D(
              onPressed: _startParSequence,
              enabled: !_isBusy,
              label: _buttonLabel,
              icon: _hasFinished ? Icons.replay : Icons.play_arrow,
              backgroundColor: _hasFinished ? tokens.accent : tokens.primary,
              textColor: tokens.onPrimary,
              height: 62,
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
