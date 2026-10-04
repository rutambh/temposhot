import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/3d/audio_envelope_oscilloscope_3d.dart';
import '../../core/widgets/3d/backlit_lcd_display_3d.dart';
import '../../core/widgets/3d/tactile_pusher_button_3d.dart';
import '../../core/widgets/3d/tactile_timer_chassis_3d.dart';
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
    // ref.watch, not ref.read: an autoDispose provider with no listener is
    // torn down on the next frame, which would release the microphone while
    // the timer is still running. Watching here ties both to this screen.
    ref.watch(audioCaptureSourceProvider);
    ref.watch(shotEngineProvider);

    final shots = _engine.recordedShots;
    final lastSplit = shots.isNotEmpty ? shots.last.splitTimeSec : 0.0;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.paper),
          onPressed: () {
            _engine.stopSession();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Live-Fire Session', style: TextStyle(color: AppColors.paper)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // 3D Chrono Chassis & Backlit LCD
              TactileTimerChassis3D(
                child: Column(
                  children: [
                    BacklitLcdDisplay3D(
                      timeSec: _currentTimeSec,
                      shotCount: shots.length,
                      lastSplitSec: lastSplit,
                      isArmed: _engine.isArmed,
                      isRunning: _engine.isRunning,
                    ),
                    const SizedBox(height: 12),
                    AudioEnvelopeOscilloscope3D(
                      waveSamples: _waveBuffer,
                      threshold: widget.sensitivity,
                      height: 80,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Tap Trigger Shot Pusher (for manual or test use)
              if (_engine.isRunning)
                TactilePusherButton3D(
                  onPressed: _triggerSimulatedShot,
                  label: 'RECORD SHOT BREAK',
                  icon: Icons.adjust,
                  backgroundColor: AppColors.oliveLight,
                  textColor: AppColors.black,
                  height: 56,
                  fontSize: 15,
                ),

              const SizedBox(height: 12),

              // Live Splits Table
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.blackCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.olive.withAlpha(70)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SHOT #', style: TextStyle(color: AppColors.paperMuted, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('SPLIT TIME', style: TextStyle(color: AppColors.paperMuted, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('CUMULATIVE', style: TextStyle(color: AppColors.paperMuted, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      const Divider(color: AppColors.olive, height: 16),
                      Expanded(
                        child: _captureUnavailableReason != null
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.mic_off_outlined,
                                        color: AppColors.blazeBright, size: 32),
                                    const SizedBox(height: 10),
                                    Text(
                                      _captureUnavailableReason!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.blazeBright,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Shots must be recorded manually below.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.paperMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : shots.isEmpty
                            ? Center(
                                child: Text(
                                  _engine.isArmed
                                      ? 'STANDBY FOR START BEEP...'
                                      : 'Listening for shot breaks...',
                                  style: TextStyle(
                                    color: _engine.isArmed ? AppColors.blazeBright : AppColors.paperMuted,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: shots.length,
                                itemBuilder: (context, idx) {
                                  final s = shots[idx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('#${s.shotNumber}', style: const TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                        Text('+${s.splitTimeSec.toStringAsFixed(2)}s', style: const TextStyle(color: AppColors.lcdAmberText, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                        Text('${s.cumulativeTimeSec.toStringAsFixed(2)}s', style: const TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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

              const SizedBox(height: 14),

              // Stop & Review Button
              TactilePusherButton3D(
                onPressed: _stopAndReview,
                label: 'STOP & REVIEW STRING',
                icon: Icons.stop_circle,
                backgroundColor: AppColors.blaze,
                height: 64,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
