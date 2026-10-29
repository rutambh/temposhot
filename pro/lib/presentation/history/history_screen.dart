import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/field_notebook_theme.dart';
import '../../core/widgets/paper_card.dart';
import '../paywall/pro_paywall_screen.dart';
import '../providers/app_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FieldNotebookTheme.of(context);
    final stringsAsync = ref.watch(allStringsProvider);
    final countAsync = ref.watch(stringCountProvider);

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
          'String logbook',
          style: tokens.body(color: tokens.text, size: 17, weight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
              );
            },
            child: Text(
              'Upgrade Pro',
              style: TextStyle(
                  color: tokens.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            countAsync.when(
              data: (count) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PaperCard(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      Icon(Icons.storage, color: tokens.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lite storage: $count / ${AppConstants.liteMaxStrings} strings',
                          style: tokens.body(
                              color: tokens.text, size: 13, weight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            stringsAsync.when(
              data: (strings) {
                if (strings.isEmpty) {
                  // Composed empty state, not a blank panel.
                  return PaperCard(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      children: [
                        Icon(Icons.timer_outlined, color: tokens.accent, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'No strings logged yet',
                          style: tokens.body(
                              color: tokens.text, size: 16, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Run a live-fire or dry-fire session and the splits will be written here.',
                          textAlign: TextAlign.center,
                          style: tokens.body(color: tokens.textMuted, size: 13),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: strings.map((s) {
                    final dt = DateTime.tryParse(s.timestamp) ?? DateTime.now();
                    final dateStr = DateFormat('MMM d, HH:mm').format(dt);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PaperCard(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dateStr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: tokens.body(color: tokens.text,
                                        size: 15, weight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${s.totalTimeSec.toStringAsFixed(2)}s',
                                  style: tokens.readout(
                                      color: tokens.primary, size: 19),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildPill('Draw: ${s.firstShotDelaySec.toStringAsFixed(2)}s',
                                    tokens.warning),
                                const SizedBox(width: 8),
                                _buildPill('100% offline', tokens.textMuted),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: tokens.primary),
              ),
              error: (err, _) => PaperCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage_outlined,
                            color: tokens.error, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Logbook unavailable',
                          style: tokens.body(
                            color: tokens.text,
                            size: 15,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The local database could not be opened. Saved strings '
                      'are safe on this device; try again, or restart the app '
                      'if the problem continues.\n\n$err',
                      style: tokens.body(color: tokens.textMuted, size: 12),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          ref.invalidate(allStringsProvider);
                          ref.invalidate(stringCountProvider);
                        },
                        icon: Icon(Icons.refresh, color: tokens.primary),
                        label: Text(
                          'Retry',
                          style: TextStyle(
                            color: tokens.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
