import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/field_notebook_theme.dart';
import '../../core/widgets/3d/audio_envelope_oscilloscope_3d.dart';
import '../../core/widgets/3d/backlit_lcd_display_3d.dart';
import '../../core/widgets/3d/tactile_pusher_button_3d.dart';
import '../../core/widgets/3d/tactile_timer_chassis_3d.dart';
import '../../core/widgets/paper_card.dart';
import '../../domain/engine/shot_detection_engine.dart';
import '../../data/datasources/audio_capture_source.dart';
import '../../domain/models/shot_string.dart';
import '../providers/app_providers.dart';
import '../summary/string_summary_screen.dart';

class LiveTimerScreen extends ConsumerStatefulWidget {
  final double sensitivity;

  const LiveTimerScreen({super.key, required this.sensitivity});

  @override
  ConsumerState<LiveTimerScreen> createState() => _LiveTimerScreenState();
}

class _LiveTimerScreenState extends ConsumerState<LiveTimerScreen> {
  late ShotDetectionEngine _engine;
  Timer? _renderTimer;
  StreamSubscription<AudioSample>? _audioSub;

  double _currentTimeSec = 0.0;
  final List<double> _waveBuffer = List.generate(40, (_) => 0.0);

  /// Set once capture has told us it cannot run, e.g. permission refused.
  String? _captureUnavailableReason;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(shotEngineProvider);
    _engine.sensitivityThreshold = widget.sensitivity;
    _engine.resetSession();

    // Arm with random delay
    _engine.armTimer(
      onArmed: (delay) {
        if (mounted) setState(() {});
      },
      onStartBeep: () {
        if (mounted) {
          setState(() {});
          _startLiveTimerLoop();
        }
      },
    );

    // Open the microphone and feed captured loudness into the detector.
    _listenForShots();
  }

  Future<void> _listenForShots() async {
    final source = ref.read(audioCaptureSourceProvider);
    // If capture already knows it cannot run -- permission refused, no mic --
    // surface the reason instead of asking the device again.
    if (!source.isAvailable) {
      if (mounted) {
        setState(() => _captureUnavailableReason = source.unavailableReason);
      }
      return;
    }
    _audioSub = source.samples.listen(_onAudioSample);
    await source.start();
    if (!mounted) return;
    if (!source.isAvailable) {
      // Refused while we were asking.
      await _audioSub?.cancel();
      _audioSub = null;
      setState(() => _captureUnavailableReason = source.unavailableReason);
    }
  }

  /// One captured audio block: drive the oscilloscope and try to detect a shot.
  void _onAudioSample(AudioSample sample) {
    if (!mounted) return;
    setState(() {
      _waveBuffer.removeAt(0);
      _waveBuffer.add(sample.amplitude);
      _engine.processAudioSample(sample.amplitude,
          eventTime: sample.capturedAt);
    });
  }

  void _startLiveTimerLoop() {
    _renderTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_engine.isRunning && _engine.startBeepTime != null) {
        final now = DateTime.now();
        setState(() {
          _currentTimeSec = now.difference(_engine.startBeepTime!).inMicroseconds / 1000000.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _renderTimer?.cancel();
    _audioSub?.cancel();
    _engine.stopSession();
    super.dispose();
  }

  void _triggerSimulatedShot() {
    if (_engine.isRunning) {
      // Spike the oscilloscope
      setState(() {
        _waveBuffer[_waveBuffer.length - 1] = 0.95;
      });
      _engine.registerManualShot();
      setState(() {});
    }
  }

  void _stopAndReview() {
    _renderTimer?.cancel();
    _audioSub?.cancel();
    _engine.stopSession();

    final now = DateTime.now();
    final shotString = ShotString(
      timestamp: now.toIso8601String(),
      totalTimeSec: _engine.totalTimeSec > 0 ? _engine.totalTimeSec : _currentTimeSec,
      firstShotDelaySec: _engine.firstShotDelaySec,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StringSummaryScreen(
          shotString: shotString,
          shots: _engine.recordedShots.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    // ref.watch, not ref.read: an autoDispose provider with no listener is
    // torn down on the next frame, which would release the microphone while
    // the timer is still running. Watching here ties both to this screen.
    ref.watch(audioCaptureSourceProvider);
    ref.watch(shotEngineProvider);

    final shots = _engine.recordedShots;
    final lastSplit = shots.isNotEmpty ? shots.last.splitTimeSec : 0.0;

    return Scaffold(
      // Transparent so the app shell's dot-grid paper reads through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.text),
          onPressed: () {
            _engine.stopSession();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Live-fire session',
          style: tokens.body(
            color: tokens.text,
            size: 17,
            weight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Column(
            children: [
              TactileTimerChassis3D(
                padding: 12,
                child: Column(
                  children: [
                    BacklitLcdDisplay3D(
                      timeSec: _currentTimeSec,
                      shotCount: shots.length,
                      lastSplitSec: lastSplit,
                      isArmed: _engine.isArmed,
                      isRunning: _engine.isRunning,
                    ),
                    const SizedBox(height: 10),
                    AudioEnvelopeOscilloscope3D(
                      waveSamples: _waveBuffer,
                      threshold: widget.sensitivity,
                      height: 72,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Manual shot trigger, for dry runs and for a string the mic
              // missed. Only present once the timer is actually running.
              if (_engine.isRunning)
                TactilePusherButton3D(
                  onPressed: _triggerSimulatedShot,
                  label: 'RECORD SHOT BREAK',
                  icon: Icons.adjust,
                  backgroundColor: tokens.accent,
                  textColor: tokens.onPrimary,
                  height: 52,
                  fontSize: 15,
                ),

              if (_engine.isRunning) const SizedBox(height: 12),

              // The splits table -- the actual written record of the string.
              Expanded(
                child: PaperCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'SHOT #',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tokens.label(color: tokens.textMuted, size: 10),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'SPLIT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: tokens.label(color: tokens.textMuted, size: 10),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'CUMULATIVE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: tokens.label(color: tokens.textMuted, size: 10),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: tokens.border, height: 12),
                      Expanded(
                        child: _captureUnavailableReason != null
                            ? _CaptureUnavailable(reason: _captureUnavailableReason!)
                            : shots.isEmpty
                                ? Center(
                                    child: Text(
                                      _engine.isArmed
                                          ? 'Standby for the start beep.'
                                          : 'Listening for shot breaks.',
                                      textAlign: TextAlign.center,
                                      style: tokens.body(
                                        color: _engine.isArmed
                                            ? tokens.primary
                                            : tokens.textMuted,
                                        size: 13,
                                        weight: FontWeight.w600,
                                      ).copyWith(fontFamily: tokens.readoutFontFamily),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: shots.length,
                                    itemBuilder: (context, idx) {
                                      final s = shots[idx];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '#${s.shotNumber}',
                                                maxLines: 1,
                                                style: tokens.readout(
                                                  color: tokens.text,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '+${s.splitTimeSec.toStringAsFixed(2)}s',
                                                maxLines: 1,
                                                textAlign: TextAlign.right,
                                                style: tokens.readout(
                                                  color: tokens.warning,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${s.cumulativeTimeSec.toStringAsFixed(2)}s',
                                                maxLines: 1,
                                                textAlign: TextAlign.right,
                                                style: tokens.readout(
                                                  color: tokens.text,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TactilePusherButton3D(
                onPressed: _stopAndReview,
                label: 'STOP & REVIEW STRING',
                icon: Icons.stop_circle,
                backgroundColor: tokens.primary,
                textColor: tokens.onPrimary,
                height: 58,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown in place of the splits table when the microphone cannot run.
/// Says what failed and what to do instead -- no silent blank panel.
class _CaptureUnavailable extends StatelessWidget {
  const _CaptureUnavailable({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_off_outlined, color: tokens.accent, size: 30),
            const SizedBox(height: 10),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: tokens.body(
                color: tokens.text,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Record shots manually with the button above.',
              textAlign: TextAlign.center,
              style: tokens.body(color: tokens.textMuted, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}