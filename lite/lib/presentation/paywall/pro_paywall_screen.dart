import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class ProPaywallScreen extends StatelessWidget {
  const ProPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Upgrade to TempoShot Pro', style: TextStyle(color: AppColors.paper)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blaze.withAlpha(30),
                  border: Border.all(color: AppColors.blaze, width: 2),
                ),
                child: const Icon(Icons.timer_outlined, color: AppColors.blaze, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock Match-Grade Shot Timing',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.paper,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'One-time purchase • 100% Offline • Lifetime Access',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.paperMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _buildFeatureTile(
              icon: Icons.all_inclusive,
              title: 'Unlimited Practice Strings',
              subtitle: 'Store your entire training history without 10-string Lite limit.',
            ),
            _buildFeatureTile(
              icon: Icons.fitness_center,
              title: 'Full Match Drill Library',
              subtitle: 'Create unlimited custom drills, par stages, and multiple shooter profiles.',
            ),
            _buildFeatureTile(
              icon: Icons.graphic_eq,
              title: 'Calibrated Gun Sensitivity Profiles',
              subtitle: 'Pre-calibrated thresholds for .22 LR, 9mm, PCC, and 12 Gauge Shotgun.',
            ),
            _buildFeatureTile(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Printable Range Scorecard PDF',
              subtitle: 'Export clean PDF drill cards with split trend histograms.',
            ),
            _buildFeatureTile(
              icon: Icons.share,
              title: 'CSV Match Export',
              subtitle: 'Full split-by-split timestamps for Squad Locker and Excel.',
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  'Get TempoShot Pro (\$14.99)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blaze,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () async {
                  final uri = Uri.parse(AppConstants.playStoreUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Package: com.rutambh.temposhot.pro',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.oliveLight, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blackCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.olive.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blackSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.blaze, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.paperMuted,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
