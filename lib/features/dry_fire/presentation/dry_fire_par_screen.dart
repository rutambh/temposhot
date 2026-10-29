import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/audio/cue_player.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/ballistic_theme.dart';
import '../../../shared/widgets/ballistic_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../../shared/widgets/status_indicator_badge.dart';
import '../../../shared/widgets/tactile_pusher_button.dart';

class DryFireParScreen extends StatefulWidget {
  final Duration? testLeadInDelay;

  const DryFireParScreen({super.key, this.testLeadInDelay});

  @override
  State<DryFireParScreen> createState() => _DryFireParScreenState();
}

enum ParState {
  idle,
  leadIn,
  running,
  parExpired,
}

class _DryFireParScreenState extends State<DryFireParScreen> {
  double _targetParSec = 2.50;
  ParState _state = ParState.idle;
  double _elapsedSec = 0.0;
  Timer? _leadInTimer;
  Timer? _parTimer;
  Timer? _renderTimer;
  DateTime? _parStartTime;
  final CuePlayer _cuePlayer = CuePlayer();

  @override
  void dispose() {
    _leadInTimer?.cancel();
    _parTimer?.cancel();
    _renderTimer?.cancel();
    unawaited(_cuePlayer.dispose());
    super.dispose();
  }

  void _startParSession() {
    _stopSession();

    setState(() {
      _state = ParState.leadIn;
      _elapsedSec = 0.0;
    });

    final leadInDuration = widget.testLeadInDelay ?? const Duration(seconds: 2);

    _leadInTimer = Timer(leadInDuration, () {
      if (!mounted) return;
      unawaited(_cuePlayer.beep()); // Start buzzer
      _parStartTime = DateTime.now();

      setState(() {
        _state = ParState.running;
      });

      _renderTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        if (!mounted || _parStartTime == null) return;
        final elapsed = DateTime.now()
                .difference(_parStartTime!)
                .inMicroseconds /
            1000000.0;
        setState(() {
          _elapsedSec = elapsed;
        });
      });

      _parTimer = Timer(
        Duration(milliseconds: (_targetParSec * 1000).round()),
        () {
          if (!mounted) return;
          unawaited(_cuePlayer.beep()); // Par buzzer
          _renderTimer?.cancel();
          setState(() {
            _state = ParState.parExpired;
            _elapsedSec = _targetParSec;
          });
        },
      );
    });
  }

  void _stopSession() {
    _leadInTimer?.cancel();
    _parTimer?.cancel();
    _renderTimer?.cancel();
    setState(() {
      _state = ParState.idle;
      _elapsedSec = 0.0;
    });
  }

  void _adjustPar(double delta) {
    if (_state != ParState.idle) return;
    setState(() {
      _targetParSec = (_targetParSec + delta).clamp(0.50, 10.00);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);

    String statusText;
    Color statusColor;

    switch (_state) {
      case ParState.idle:
        statusText = 'PAR READY';
        statusColor = tokens.borderStrong;
        break;
      case ParState.leadIn:
        statusText = 'STAND BY...';
        statusColor = tokens.primary;
        break;
      case ParState.running:
        statusText = 'DRAW & FIRE!';
        statusColor = tokens.primary;
        break;
      case ParState.parExpired:
        statusText = 'PAR BUZZER!';
        statusColor = tokens.success;
        break;
    }

    final displayTime = _state == ParState.idle
        ? _targetParSec
        : _elapsedSec;

    return ResponsiveScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Nav
            Row(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DRY-FIRE PAR TRAINER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: tokens.text,
                        ),
                      ),
                      Text(
                        'ACOUSTIC BUZZER INTERVALS',
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
                    label: statusText,
                    dotColor: statusColor,
                    isPulsing: _state == ParState.running || _state == ParState.leadIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Master Par Display Chassis
            BallisticCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayTime.toStringAsFixed(2).padLeft(5, '0'),
                      style: TextStyle(
                        fontFamily: 'PublicSans',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w900,
                        fontSize: 76,
                        letterSpacing: -1.0,
                        color: _state == ParState.parExpired
                            ? tokens.success
                            : tokens.text,
                      ),
                    ),
                  ),
                  Text(
                    _state == ParState.idle ? 'TARGET PAR SECONDS' : 'ELAPSED SECONDS',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 2.0,
                      color: tokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Progress indicator during run
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _state == ParState.idle
                          ? 1.0
                          : (_elapsedSec / _targetParSec).clamp(0.0, 1.0),
                      backgroundColor: tokens.surfaceSub,
                      color: _state == ParState.parExpired
                          ? tokens.success
                          : tokens.primary,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Target Par Selector Card
            BallisticCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'TARGET PAR ADJUSTMENT',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                      color: tokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Column(
                    children: [
                      Text(
                        '${_targetParSec.toStringAsFixed(2)}s',
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: tokens.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildAdjustButton(tokens, '-0.50s', () => _adjustPar(-0.50)),
                          _buildAdjustButton(tokens, '-0.10s', () => _adjustPar(-0.10)),
                          _buildAdjustButton(tokens, '+0.10s', () => _adjustPar(0.10)),
                          _buildAdjustButton(tokens, '+0.50s', () => _adjustPar(0.50)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Preset Chips
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [1.50, 1.80, 2.00, 2.50, 3.00, 3.50].map((preset) {
                      final isSelected = (_targetParSec - preset).abs() < 0.01;
                      return ChoiceChip(
                        label: Text('${preset.toStringAsFixed(2)}s'),
                        selected: isSelected,
                        onSelected: _state == ParState.idle
                            ? (_) => setState(() => _targetParSec = preset)
                            : null,
                        selectedColor: tokens.primary,
                        backgroundColor: tokens.surfaceSub,
                        labelStyle: TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isSelected ? Colors.white : tokens.text,
                        ),
                        side: BorderSide(
                          color: isSelected ? tokens.primaryHover : tokens.border,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Pushers
            TactilePusherButton(
              label: _state == ParState.idle
                  ? 'START PAR TIMER (2s DELAY)'
                  : 'STOP PAR TIMER',
              icon: _state == ParState.idle ? Icons.play_arrow : Icons.stop,
              variant: _state == ParState.idle ? PusherVariant.primary : PusherVariant.danger,
              onPressed: () {
                if (_state == ParState.idle) {
                  _startParSession();
                } else {
                  _stopSession();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustButton(BallisticTokens tokens, String label, VoidCallback onPressed) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: tokens.surfaceSub,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: tokens.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: tokens.text,
            ),
          ),
        ),
      ),
    );
  }
}
