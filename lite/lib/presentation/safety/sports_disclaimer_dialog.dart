import 'package:flutter/material.dart';
import '../../core/theme/field_notebook_theme.dart';

class SportsDisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const SportsDisclaimerDialog({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    return Dialog(
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokens.border, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: tokens.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sports safety disclaimer',
                    style: tokens.body(
                        color: tokens.text, size: 18, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'TempoShot is an offline acoustic sports timer designed exclusively for competitive practical shooting (USPSA/IDPA) and dry-fire par practice.\n\n'
              '• Always observe the 4 Universal Firearm Safety Rules.\n'
              '• Wear certified eye and hearing protection during all live-fire training.\n'
              '• TempoShot does not connect to any firearm hardware or store location/firearm data.\n'
              '• 100% offline & private: zero telemetry, zero cloud.',
              style: tokens.body(color: tokens.textMuted, size: 14, height: 1.45),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onAccept,
                child: const Text(
                  'I Understand & Agree',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
