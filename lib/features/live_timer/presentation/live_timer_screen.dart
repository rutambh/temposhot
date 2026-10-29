import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_capture_source.dart';
import '../../../core/audio/cue_player.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/ballistic_theme.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../../shared/widgets/status_indicator_badge.dart';
import '../../../shared/widgets/tactile_pusher_button.dart';
import '../../summary/presentation/string_summary_screen.dart';
import '../domain/shot_detection_engine.dart';
import 'providers/live_timer_providers.dart';
import 'widgets/audio_oscilloscope_strip.dart';
import 'widgets/live_readout_panel.dart';
import 'widgets/real_time_splits_table.dart';

class LiveTimerScreen extends ConsumerStatefulWidget {
  final Duration? testStartDelay;

  const LiveTimerScreen({super.key, this.testStartDelay});

  @override
  ConsumerState<LiveTimerScreen> createState() => _LiveTimerScreenState();
}

class _LiveTimerScreenState extends ConsumerState<LiveTimerScreen>
    with WidgetsBindingObserver {
  late ShotDetectionEngine _engine;
  late AudioCaptureSource _audioSource;
  Timer? _renderTimer;
  StreamSubscription<AudioSample>? _audioSub;
  final CuePlayer _cuePlayer = CuePlayer();

  double _currentTimeSec = 0.0;
  final List<double> _waveBuffer = List.generate(40, (_) => 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop recording and release microphone if app is backgrounded (fixes IMP-01)
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_engine.isRunning || _engine.isArmed) {
        _stopSession();
      }
    }
  }

  void _armSession() {
    _engine.armTimer(
      startDelay: widget.testStartDelay,
      onArmed: (delay) {
        if (mounted) setState(() {});
      },
      onStartBeep: () {
        if (!mounted) return;
        unawaited(_cuePlayer.beep());
        setState(() {});
        _startLiveTimerLoop();
      },
    );
  }

  void _startLiveTimerLoop() {
    _renderTimer?.cancel();
    _renderTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) return;
      if (_engine.isRunning && _engine.startBeepTime != null) {
        setState(() {
          _currentTimeSec = DateTime.now()
                  .difference(_engine.startBeepTime!)
                  .inMicroseconds /
              1000000.0;
        });
      }
    });
  }

  void _onAudioSample(AudioSample sample) {
    if (!mounted) return;
    _waveBuffer.removeAt(0);
    _waveBuffer.add(sample.amplitude);

    if (_engine.isRunning) {
      final shotFired = _engine.processAudioSample(
        sample.amplitude,
        eventTime: sample.capturedAt,
      );
      if (shotFired) {
        setState(() {});
      }
    } else {
      setState(() {});
    }
  }

  void _stopSession() {
    _renderTimer?.cancel();
    _engine.stopSession();
    setState(() {});
  }

  void _navigateToSummary() {
    _stopSession();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StringSummaryScreen(
          shots: _engine.recordedShots,
          totalTimeSec: _engine.totalTimeSec,
          firstShotDelaySec: _engine.firstShotDelaySec,
          drillName: 'Bill Drill (6 Shots)',
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _renderTimer?.cancel();
    _audioSub?.cancel();
    unawaited(_audioSource.stop());
    _engine.stopSession();
    unawaited(_cuePlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);

    // Watch providers in build to tie capture lifecycle to screen visibility
    _audioSource = ref.watch(audioCaptureSourceProvider);
    _engine = ref.watch(shotEngineProvider);

    // Initialize audio subscription once source is available
    if (_audioSub == null) {
      _audioSub = _audioSource.samples.listen(_onAudioSample);
      _audioSource.start();
    }

    final isSessionActive = _engine.isArmed || _engine.isRunning;

    return ResponsiveScaffold(
      body: CustomScrollView(
        slivers: [
          // Tactical Header
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
                    label: 'Go back',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BILL DRILL · 6 SHOTS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.0,
                            color: tokens.text,
                          ),
                        ),
                        Text(
                          'PAR: 2.50s · SENSITIVITY 0.65',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PublicSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    fit: FlexFit.loose,
                    child: StatusIndicatorBadge(
                      label: _audioSource.isAvailable ? 'MIC ACTIVE' : 'MANUAL',
                      dotColor: _audioSource.isAvailable ? tokens.primary : tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Telemetry Readout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: LiveReadoutPanel(
                currentTimeSec: _engine.isRunning ? _currentTimeSec : _engine.totalTimeSec,
                isArmed: _engine.isArmed,
                isRunning: _engine.isRunning,
                firstShotSec: _engine.firstShotDelaySec,
                lastSplitSec: _engine.recordedShots.length > 1
                    ? _engine.recordedShots.last.splitTimeSec
                    : 0.0,
                shotCount: _engine.recordedShots.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          // Oscilloscope Strip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: AudioOscilloscopeStrip(
                waveBuffer: _waveBuffer,
                threshold: _engine.detectionThreshold,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          // Splits Table
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: RealTimeSplitsTable(
                shots: _engine.recordedShots,
                onDeleteShot: (idx) {
                  _engine.deleteShot(idx);
                  setState(() {});
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          // Action Controls
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TactilePusherButton(
                    label: isSessionActive
                        ? 'STOP & REVIEW STRING'
                        : 'ARM TIMER · STAND BY',
                    icon: isSessionActive ? Icons.stop : Icons.play_arrow,
                    variant: PusherVariant.primary,
                    onPressed: () {
                      if (isSessionActive) {
                        _navigateToSummary();
                      } else {
                        _armSession();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TactilePusherButton(
                          label: '+ MANUAL SHOT',
                          variant: PusherVariant.secondary,
                          height: AppSpacing.secondaryButtonHeight,
                          onPressed: () {
                            if (!_engine.isRunning) {
                              _armSession();
                            }
                            _engine.registerManualShot();
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TactilePusherButton(
                          label: 'DISCARD',
                          variant: PusherVariant.secondary,
                          height: AppSpacing.secondaryButtonHeight,
                          onPressed: () {
                            _stopSession();
                            _engine.resetSession();
                            setState(() {
                              _currentTimeSec = 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
