import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Practice String Summary', style: TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.paper),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.blackCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.olive.withAlpha(80), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(200),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('TOTAL STRING TIME', style: TextStyle(color: AppColors.paperMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Text(
                      '${totalTime.toStringAsFixed(2)}s',
                      style: const TextStyle(
                        color: AppColors.blazeBright,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol('FIRST SHOT', '${firstShot.toStringAsFixed(2)}s'),
                        _buildMetricCol('FASTEST SPLIT', '${fastestSplit.toStringAsFixed(2)}s'),
                        _buildMetricCol('AVG SPLIT', '${avgSplit.toStringAsFixed(2)}s'),
                        _buildMetricCol('SHOTS', '${_currentShots.length}'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Split Breakdown List with Errant Shot Deletion
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.blackCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.olive.withAlpha(60)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SHOT BREAKDOWN (Tap trash icon to remove errant echo)',
                        style: TextStyle(color: AppColors.paperMuted, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: AppColors.olive, height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _currentShots.length,
                          itemBuilder: (context, idx) {
                            final s = _currentShots[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text('#${s.shotNumber}', style: const TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 15)),
                                  const SizedBox(width: 16),
                                  Text('Split: +${s.splitTimeSec.toStringAsFixed(2)}s', style: const TextStyle(color: AppColors.lcdAmberText, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  const Spacer(),
                                  Text('${s.cumulativeTimeSec.toStringAsFixed(2)}s', style: const TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.oliveLight, size: 20),
                                    tooltip: 'Delete Errant Shot',
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
                    backgroundColor: AppColors.blaze,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildMetricCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.paperMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.paper, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
      ],
    );
  }
}
