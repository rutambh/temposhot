import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_flavor.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/ballistic_theme.dart';
import 'ballistic_card.dart';
import 'tactile_pusher_button.dart';

/// Centralized friendly upgrade dialog shown whenever Lite limits are encountered.
class UpgradePromptDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? alternativeActionLabel;
  final VoidCallback? onAlternativeAction;

  const UpgradePromptDialog({
    super.key,
    this.title = 'Unlock TempoShot Pro',
    this.message =
        'TempoShot Lite stores up to 10 strings. Upgrade to Pro for unlimited strings, custom drill presets, and CSV export — with a one-time purchase and zero subscription.',
    this.alternativeActionLabel,
    this.onAlternativeAction,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    String? alternativeActionLabel,
    VoidCallback? onAlternativeAction,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => UpgradePromptDialog(
        title: title ?? 'Unlock TempoShot Pro',
        message: message ??
            'TempoShot Lite stores up to 10 strings. Upgrade to Pro for unlimited strings, custom drill presets, and CSV export — with a one-time purchase and zero subscription.',
        alternativeActionLabel: alternativeActionLabel,
        onAlternativeAction: onAlternativeAction,
      ),
    );
  }

  Future<void> _openPlayStore(BuildContext context) async {
    final url = Uri.parse(AppFlavorConfig.current.proPlayStoreUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: BallisticCard(
          surfaceColor: tokens.surface,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: tokens.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                        color: tokens.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontSize: 14,
                  height: 1.5,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Pro feature check-items
              _buildFeatureItem(tokens, 'Unlimited Saved Strings & Splits'),
              _buildFeatureItem(tokens, 'Custom Drills & Target Par Settings'),
              _buildFeatureItem(tokens, 'Detailed CSV Data Export'),
              _buildFeatureItem(tokens, '100% Offline, Zero Cloud Telemetry'),
              const SizedBox(height: AppSpacing.xl),
              TactilePusherButton(
                label: 'GET PRO · PLAY STORE',
                icon: Icons.open_in_new,
                variant: PusherVariant.primary,
                height: 54,
                onPressed: () => _openPlayStore(context),
              ),
              if (alternativeActionLabel != null && onAlternativeAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TactilePusherButton(
                  label: alternativeActionLabel!,
                  variant: PusherVariant.secondary,
                  height: 46,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAlternativeAction!();
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'NOT NOW',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.0,
                    color: tokens.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BallisticTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: tokens.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tokens.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
