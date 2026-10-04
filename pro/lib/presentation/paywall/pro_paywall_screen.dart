import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/field_notebook_theme.dart';
import '../../core/widgets/paper_card.dart';

class ProPaywallScreen extends StatelessWidget {
  const ProPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Upgrade to TempoShot Pro', style: TextStyle(color: tokens.text)),
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
                  color: tokens.primary.withAlpha(30),
                  border: Border.all(color: tokens.primary, width: 2),
                ),
                child: Icon(Icons.timer_outlined, color: tokens.primary, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock match-grade shot timing',
              textAlign: TextAlign.center,
              style: tokens.body(
                  color: tokens.text, size: 22, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'One-time purchase • 100% offline • lifetime access',
              textAlign: TextAlign.center,
              style: tokens.body(color: tokens.textMuted, size: 13),
            ),
            const SizedBox(height: 24),

            _buildFeatureTile(
              tokens,
              icon: Icons.all_inclusive,
              title: 'Unlimited Practice Strings',
              subtitle: 'Store your entire training history without 10-string Lite limit.',
            ),
            _buildFeatureTile(
              tokens,
              icon: Icons.fitness_center,
              title: 'Full Match Drill Library',
              subtitle: 'Create unlimited custom drills, par stages, and multiple shooter profiles.',
            ),
            _buildFeatureTile(
              tokens,
              icon: Icons.graphic_eq,
              title: 'Calibrated Gun Sensitivity Profiles',
              subtitle: 'Pre-calibrated thresholds for .22 LR, 9mm, PCC, and 12 Gauge Shotgun.',
            ),
            _buildFeatureTile(
              tokens,
              icon: Icons.picture_as_pdf_outlined,
              title: 'Printable Range Scorecard PDF',
              subtitle: 'Export clean PDF drill cards with split trend histograms.',
            ),
            _buildFeatureTile(
              tokens,
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
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
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
            Text(
              'Package: com.rutambh.temposhot.pro',
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    FieldNotebookTokens tokens, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PaperCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: tokens.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tokens.body(
                        color: tokens.text, size: 15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: tokens.body(color: tokens.textMuted, size: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
