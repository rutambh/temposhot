import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/field_notebook_theme.dart';
import '../../core/widgets/paper_card.dart';
import '../../domain/models/shot_record.dart';
import '../../domain/models/shot_string.dart';
import '../providers/app_providers.dart';

class StringSummaryScreen extends ConsumerStatefulWidget {
  final ShotString shotString;
  final List<ShotRecord> shots;

  const StringSummaryScreen({
    super.key,
    required this.shotString,
    required this.shots,
  });

  @override
  ConsumerState<StringSummaryScreen> createState() => _StringSummaryScreenState();
}

class _StringSummaryScreenState extends ConsumerState<StringSummaryScreen> {
  late List<ShotRecord> _currentShots;

  @override
  void initState() {
    super.initState();
    _currentShots = List.from(widget.shots);
  }

  void _deleteShot(int index) {
    if (index >= 0 && index < _currentShots.length) {
      setState(() {
        _currentShots.removeAt(index);
        // Recompute cumulative and splits
        for (int i = 0; i < _currentShots.length; i++) {
          final s = _currentShots[i];
          final prevCumul = i == 0 ? 0.0 : _currentShots[i - 1].cumulativeTimeSec;
          final split = s.cumulativeTimeSec - prevCumul;
          _currentShots[i] = ShotRecord(
            id: s.id,
            stringId: s.stringId,
            shotNumber: i + 1,
            splitTimeSec: double.parse(split.toStringAsFixed(2)),
            cumulativeTimeSec: s.cumulativeTimeSec,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    final totalTime = _currentShots.isNotEmpty ? _currentShots.last.cumulativeTimeSec : 0.0;
    final firstShot = _currentShots.isNotEmpty ? _currentShots.first.cumulativeTimeSec : 0.0;

    double fastestSplit = 0.0;
    double avgSplit = 0.0;
    if (_currentShots.length > 1) {
      final splits = _currentShots.sublist(1).map((s) => s.splitTimeSec).toList();
      fastestSplit = splits.reduce((a, b) => a < b ? a : b);
      avgSplit = splits.reduce((a, b) => a + b) / splits.length;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'String summary',
          style: tokens.body(color: tokens.text, size: 17, weight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: tokens.text),
            tooltip: 'Share String',
            onPressed: () {
              final text = 'TempoShot String:\nTotal: ${totalTime.toStringAsFixed(2)}s\nShots: ${_currentShots.length}\nFirst Shot: ${firstShot.toStringAsFixed(2)}s\nFastest Split: ${fastestSplit.toStringAsFixed(2)}s';
              Share.share(text);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Top Scorecard Box
              PaperCard(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL STRING TIME',
                      style: tokens.label(color: tokens.textMuted),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${totalTime.toStringAsFixed(2)}s',
                        style: tokens.readout(
                          color: tokens.primary,
                          size: 52,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildMetricCol(
                            tokens, 'FIRST SHOT', '${firstShot.toStringAsFixed(2)}s'),
                        _buildMetricCol(
                            tokens, 'FASTEST SPLIT', '${fastestSplit.toStringAsFixed(2)}s'),
                        _buildMetricCol(
                            tokens, 'AVG SPLIT', '${avgSplit.toStringAsFixed(2)}s'),
                        _buildMetricCol(
                            tokens, 'SHOTS', '${_currentShots.length}'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Split Breakdown List with Errant Shot Deletion
              Expanded(
                child: PaperCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHOT BREAKDOWN — TAP TRASH TO DROP AN ERRANT ECHO',
                        maxLines: 2,
                        style: tokens.label(color: tokens.textMuted, size: 10),
                      ),
                      Divider(color: tokens.border, height: 14),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _currentShots.length,
                          itemBuilder: (context, idx) {
                            final s = _currentShots[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 26,
                                    child: Text(
                                      '#${s.shotNumber}',
                                      style: tokens.readout(color: tokens.text, size: 14),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '+${s.splitTimeSec.toStringAsFixed(2)}s',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: tokens.readout(color: tokens.warning, size: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 56,
                                    child: Text(
                                      '${s.cumulativeTimeSec.toStringAsFixed(2)}s',
                                      maxLines: 1,
                                      textAlign: TextAlign.right,
                                      style: tokens.readout(color: tokens.text, size: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: tokens.textMuted, size: 20),
                                    tooltip: 'Delete Errant Shot',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _deleteShot(idx),
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

              const SizedBox(height: 16),

              // Save & Finish CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 24),
                  label: const Text('Save String to Logbook', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.primary,
                    foregroundColor: tokens.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final db = ref.read(tempoDatabaseProvider);
                    final finalString = ShotString(
                      timestamp: widget.shotString.timestamp,
                      totalTimeSec: totalTime,
                      firstShotDelaySec: firstShot,
                    );
                    await db.insertStringWithShots(finalString, _currentShots);
                    ref.invalidate(allStringsProvider);
                    ref.invalidate(stringCountProvider);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  /// One figure in the scorecard row. Equal-width columns so the four
  /// numbers line up as a table rather than a ragged sentence.
  Widget _buildMetricCol(FieldNotebookTokens tokens, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                tokens.label(color: tokens.textMuted, size: 9, letterSpacing: 0.6),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: tokens.readout(color: tokens.text, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
