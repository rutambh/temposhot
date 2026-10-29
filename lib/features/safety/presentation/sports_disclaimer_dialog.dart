import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/ballistic_theme.dart';
import '../../../shared/widgets/ballistic_card.dart';
import '../../../shared/widgets/tactile_pusher_button.dart';

const _disclaimerPrefKey = 'temposhot_disclaimer_accepted';

class SportsDisclaimerDialog extends StatelessWidget {
  const SportsDisclaimerDialog({super.key});

  static Future<bool> isAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_disclaimerPrefKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_disclaimerPrefKey, true);
    } catch (_) {}
  }

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const SportsDisclaimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
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
                      color: tokens.alert,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.shield, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'SAFETY & SPORTS NOTICE',
                      style: TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: tokens.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'TempoShot is an acoustic audio timer engineered exclusively for sports timing, dry-fire practice, and target competition.',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontSize: 14,
                  height: 1.5,
                  color: tokens.text,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildBullet(tokens, 'Always wear certified ANSI-approved eye and ear protection when on a live range.'),
              _buildBullet(tokens, 'This app is not connected to any firearm hardware, action, or trigger mechanism.'),
              _buildBullet(tokens, 'All audio analysis is performed on-device in volatile memory and is never transmitted.'),
              const SizedBox(height: AppSpacing.xl),
              TactilePusherButton(
                label: 'I UNDERSTAND & ACCEPT',
                icon: Icons.check,
                variant: PusherVariant.primary,
                height: 54,
                onPressed: () async {
                  await markAccepted();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(BallisticTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: tokens.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontSize: 13,
                height: 1.4,
                color: tokens.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
