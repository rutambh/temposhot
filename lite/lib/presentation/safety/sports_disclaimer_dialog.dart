import 'package:flutter/material.dart';
import '../../core/theme/field_notebook_theme.dart';

/// The first thing a new session sees: what the app is, the safety rules that
/// still apply, and the limits of a training aid.
class SportsDisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const SportsDisclaimerDialog({super.key, required this.onAccept});

  static const _rules = [
    'Treat every firearm as loaded.',
    'Never point a firearm at anything you are not willing to destroy.',
    'Keep your finger off the trigger until your sights are on the target.',
    'Be sure of your target and what is behind it.',
    'Wear certified eye and hearing protection whenever live fire is present.',
    'Dry-fire only with a verified unloaded firearm, no ammunition in the room, '
        'and a safe backstop.',
    'Follow your range rules and range officer at all times.',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: tokens.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.border, width: 1.5),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tokens.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: tokens.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Before you start',
                            style: tokens.body(
                              color: tokens.text,
                              size: 19,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Training aid — not a safety device',
                            style: tokens.label(color: tokens.accent, size: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TempoShot is an offline acoustic shot timer and '
                          'dry-fire par trainer for practical shooting practice '
                          '(USPSA / IDPA). It listens to sound impulses. It does '
                          'not connect to a firearm, score targets, or make any '
                          'safety decision for you.',
                          style: tokens.body(
                            color: tokens.textMuted,
                            size: 13.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'THE FOUR UNIVERSAL SAFETY RULES STILL APPLY',
                          style: tokens.label(color: tokens.text, size: 10),
                        ),
                        const SizedBox(height: 8),
                        for (final rule in _rules)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    size: 14,
                                    color: tokens.accent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    rule,
                                    style: tokens.body(
                                      color: tokens.textMuted,
                                      size: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.warning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: tokens.warning.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            'TempoShot is a training aid only. The developer is '
                            'not responsible for injury, death, property damage, '
                            'or any other loss arising from use of this app. '
                            'Use it at your own risk.',
                            style: tokens.body(
                              color: tokens.text,
                              size: 12.5,
                              height: 1.4,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.primary,
                      foregroundColor: tokens.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onAccept,
                    child: const Text(
                      'I UNDERSTAND — CONTINUE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
