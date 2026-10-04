import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../paywall/pro_paywall_screen.dart';
import '../providers/app_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stringsAsync = ref.watch(allStringsProvider);
    final countAsync = ref.watch(stringCountProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('String Logbook', style: TextStyle(color: AppColors.paper)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
              );
            },
            child: const Text('Upgrade Pro', style: TextStyle(color: AppColors.blazeBright, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            countAsync.when(
              data: (count) => Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.blackCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.olive.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storage, color: AppColors.blaze, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Lite Storage: $count / ${AppConstants.liteMaxStrings} Strings',
                        style: const TextStyle(color: AppColors.paper, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            stringsAsync.when(
              data: (strings) {
                if (strings.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.blackCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.olive.withAlpha(50)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.paperMuted, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'No Recorded Strings Yet',
                          style: TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Start a live-fire or dry-fire session to record splits.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.paperMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: strings.map((s) {
                    final dt = DateTime.tryParse(s.timestamp) ?? DateTime.now();
                    final dateStr = DateFormat('MMM d, HH:mm').format(dt);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blackCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.olive.withAlpha(60)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateStr,
                                style: const TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${s.totalTimeSec.toStringAsFixed(2)}s',
                                style: const TextStyle(color: AppColors.blazeBright, fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildPill('Draw: ${s.firstShotDelaySec.toStringAsFixed(2)}s', AppColors.lcdAmberText),
                              const SizedBox(width: 8),
                              _buildPill('100% Offline', AppColors.oliveLight),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.blaze)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.blaze))),
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
