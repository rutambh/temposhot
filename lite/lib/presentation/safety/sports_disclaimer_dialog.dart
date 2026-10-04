import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SportsDisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const SportsDisclaimerDialog({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.blackCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.olive, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.blaze, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sports Safety Disclaimer',
                    style: TextStyle(
                      color: AppColors.paper,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'TempoShot is an offline acoustic sports timer designed exclusively for competitive practical shooting (USPSA/IDPA) and dry-fire par practice.\n\n'
              '• Always observe the 4 Universal Firearm Safety Rules.\n'
              '• Wear certified eye and hearing protection during all live-fire training.\n'
              '• TempoShot does not connect to any firearm hardware or store location/firearm data.\n'
              '• 100% Offline & Private: Zero telemetry, zero cloud.',
              style: TextStyle(
                color: AppColors.paperMuted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blaze,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
