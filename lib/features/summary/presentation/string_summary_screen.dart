import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/config/app_flavor.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/database/temposhot_database.dart';
import '../../../core/theme/ballistic_theme.dart';
import '../../../shared/widgets/ballistic_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../../shared/widgets/tactile_pusher_button.dart';
import '../../../shared/widgets/upgrade_prompt_dialog.dart';
import '../../history/domain/models/shot_record.dart';
import '../../history/domain/models/shot_string.dart';

class StringSummaryScreen extends ConsumerStatefulWidget {
  final List<ShotRecord> shots;
  final double totalTimeSec;
  final double firstShotDelaySec;
  final String drillName;

  const StringSummaryScreen({
    super.key,
    required this.shots,
    required this.totalTimeSec,
    required this.firstShotDelaySec,
    this.drillName = 'Bill Drill (6 Shots)',
  });

  @override
  ConsumerState<StringSummaryScreen> createState() => _StringSummaryScreenState();
}

class _StringSummaryScreenState extends ConsumerState<StringSummaryScreen> {
  late List<ShotRecord> _shots;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _shots = List.from(widget.shots);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _currentTotalTime =>
      _shots.isNotEmpty ? _shots.last.cumulativeTimeSec : 0.0;

  double get _currentFirstShot =>
      _shots.isNotEmpty ? _shots.first.cumulativeTimeSec : 0.0;

  double get _fastestSplit {
    if (_shots.length <= 1) return 0.0;
    return _shots
        .skip(1)
        .map((s) => s.splitTimeSec)
        .reduce((a, b) => a < b ? a : b);
  }

  void _deleteShot(int index) {
    if (index < 0 || index >= _shots.length) return;
    setState(() {
      _shots.removeAt(index);
      for (int i = 0; i < _shots.length; i++) {
        final current = _shots[i];
        final prevCumul = i == 0 ? 0.0 : _shots[i - 1].cumulativeTimeSec;
        final split = current.cumulativeTimeSec - prevCumul;
        _shots[i] = ShotRecord(
          id: current.id,
          stringId: current.stringId,
          shotNumber: i + 1,
          splitTimeSec: double.parse(split.toStringAsFixed(2)),
          cumulativeTimeSec: current.cumulativeTimeSec,
        );
      }
    });
  }

  Future<void> _saveString() async {
    final db = TempoShotDatabase.instance;
    final maxLimit = AppFlavorConfig.current.maxSavedStrings;

    if (maxLimit != null) {
      final currentCount = await db.getStringCount();
      if (currentCount >= maxLimit) {
        if (!mounted) return;
        await UpgradePromptDialog.show(
          context,
          title: 'Lite Limit Reached (10 Strings)',
          message:
              'TempoShot Lite stores up to 10 strings. Upgrade to Pro for unlimited strings and data export, or replace your oldest string to save this run.',
          alternativeActionLabel: 'REPLACE OLDEST STRING',
          onAlternativeAction: () async {
            await _performSave(autoEvict: true);
          },
        );
        return;
      }
    }

    await _performSave(autoEvict: false);
  }

  Future<void> _performSave({required bool autoEvict}) async {
    final db = TempoShotDatabase.instance;
    final stringRecord = ShotString(
      drillId: 1,
      shooterId: 1,
      timestamp: DateTime.now().toIso8601String(),
      totalTimeSec: _currentTotalTime,
      firstShotDelaySec: _currentFirstShot,
      notes: _notesController.text.trim(),
    );

    await db.insertStringWithShots(
      stringRecord,
      _shots,
      autoEvictOldest: autoEvict,
    );

    if (!mounted) return;
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('String saved to logbook.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareString() {
    final buffer = StringBuffer();
    buffer.writeln('TempoShot String Report');
    buffer.writeln('Drill: ${widget.drillName}');
    buffer.writeln('Date: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('Total Time: ${_currentTotalTime.toStringAsFixed(2)}s');
    buffer.writeln('First Shot: ${_currentFirstShot.toStringAsFixed(2)}s');
    buffer.writeln('Shot Count: ${_shots.length}');
    buffer.writeln('--- Splits ---');
    for (final s in _shots) {
      buffer.writeln(
        '#${s.shotNumber.toString().padLeft(2, '0')}: ${s.splitTimeSec.toStringAsFixed(2)}s (Total: ${s.cumulativeTimeSec.toStringAsFixed(2)}s)',
      );
    }
    if (_notesController.text.isNotEmpty) {
      buffer.writeln('Notes: ${_notesController.text}');
    }

    Share.share(buffer.toString(), subject: 'TempoShot Drill Report');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);

    return ResponsiveScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Nav Row
            Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Back to timer',
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
                        'STRING SUMMARY',
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: tokens.text,
                        ),
                      ),
                      Text(
                        widget.drillName,
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontSize: 12,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Master Metrics Card
            BallisticCard(
              child: Column(
                children: [
                  Text(
                    '${_currentTotalTime.toStringAsFixed(2)}s',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.w900,
                      fontSize: 64,
                      color: tokens.text,
                    ),
                  ),
                  Text(
                    'TOTAL STRING TIME',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 2.0,
                      color: tokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(tokens, 'FIRST DRAW', '${_currentFirstShot.toStringAsFixed(2)}s'),
                      _buildMetric(tokens, 'FASTEST SPLIT', '${_fastestSplit.toStringAsFixed(2)}s'),
                      _buildMetric(tokens, 'SHOTS', '${_shots.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Splits Table
            BallisticCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.surfaceSub,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusLg - 1.5),
                        topRight: Radius.circular(AppSpacing.radiusLg - 1.5),
                      ),
                      border: Border(
                        bottom: BorderSide(color: tokens.border, width: 1.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            'SHOT',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: tokens.textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'SPLIT',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: tokens.textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'TOTAL',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: tokens.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _shots.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 1,
                      color: tokens.border.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final shot = _shots[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                '#${shot.shotNumber}',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: tokens.text,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${shot.splitTimeSec.toStringAsFixed(2)}s',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: tokens.text,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${shot.cumulativeTimeSec.toStringAsFixed(2)}s',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: tokens.text,
                                ),
                              ),
                            ),
                            Semantics(
                              button: true,
                              label: 'Delete shot ${shot.shotNumber}',
                              child: InkWell(
                                onTap: () => _deleteShot(index),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.close, size: 18, color: tokens.alert),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Notes Card
            BallisticCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: TextField(
                controller: _notesController,
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontSize: 14,
                  color: tokens.text,
                ),
                decoration: InputDecoration(
                  hintText: 'Add string notes (e.g. 7 yards, clean hits)...',
                  hintStyle: TextStyle(
                    fontFamily: 'PublicSans',
                    fontSize: 14,
                    color: tokens.textMuted,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Action Buttons
            TactilePusherButton(
              label: _isSaved ? 'SAVED TO LOGBOOK' : 'SAVE TO LOGBOOK',
              icon: _isSaved ? Icons.check : Icons.save,
              variant: PusherVariant.primary,
              onPressed: _isSaved ? null : _saveString,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TactilePusherButton(
                    label: 'SHARE STRING',
                    icon: Icons.share,
                    variant: PusherVariant.secondary,
                    height: AppSpacing.secondaryButtonHeight,
                    onPressed: _shareString,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TactilePusherButton(
                    label: 'DONE',
                    variant: PusherVariant.secondary,
                    height: AppSpacing.secondaryButtonHeight,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BallisticTokens tokens, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: tokens.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: tokens.text,
          ),
        ),
      ],
    );
  }
}
