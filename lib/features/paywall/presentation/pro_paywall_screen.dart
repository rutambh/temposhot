import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_flavor.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/ballistic_theme.dart';
import '../../../shared/widgets/ballistic_card.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../../shared/widgets/tactile_pusher_button.dart';

class ProPaywallScreen extends StatelessWidget {
  const ProPaywallScreen({super.key});

  Future<void> _openPlayStore(BuildContext context) async {
    final url = Uri.parse(AppFlavorConfig.current.proPlayStoreUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
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
                  child: Text(
                    'EDITION COMPARISON',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                      color: tokens.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Pro Crown Card
            BallisticCard(
              surfaceColor: tokens.surface,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: tokens.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.primaryShadow,
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.military_tech, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'TEMPOSHOT PRO',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 1.0,
                      color: tokens.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'ONE-TIME PURCHASE · \$14.99 · ZERO SUBSCRIPTIONS',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.0,
                      color: tokens.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Comparison Grid
            BallisticCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: tokens.surfaceSub,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusLg - 1.5),
                        topRight: Radius.circular(AppSpacing.radiusLg - 1.5),
                      ),
                      border: Border(bottom: BorderSide(color: tokens.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'FEATURE',
                            style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: tokens.textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'LITE',
                              style: TextStyle(
                                fontFamily: 'PublicSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: tokens.textMuted,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'PRO',
                              style: TextStyle(
                                fontFamily: 'PublicSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: tokens.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildComparisonRow(tokens, 'Saved Strings', '10 Max', 'Unlimited', false),
                  _buildComparisonRow(tokens, 'Drill Presets', '1 Drill', 'Unlimited', false),
                  _buildComparisonRow(tokens, 'CSV Data Export', 'No', 'Full Export', false),
                  _buildComparisonRow(tokens, 'Acoustic Accuracy', '150ms Lockout', '150ms Lockout', true),
                  _buildComparisonRow(tokens, 'Privacy & Offline', '100% On-Device', '100% On-Device', true),
                  _buildComparisonRow(tokens, 'Cloud / Account', 'None Required', 'None Required', true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TactilePusherButton(
              label: 'UPGRADE ON GOOGLE PLAY · \$14.99',
              icon: Icons.open_in_new,
              variant: PusherVariant.primary,
              onPressed: () => _openPlayStore(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    BallisticTokens tokens,
    String feature,
    String lite,
    String pro,
    bool isParity,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.border.withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: tokens.text,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                lite,
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontSize: 12,
                  color: tokens.textMuted,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                pro,
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isParity ? tokens.text : tokens.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
