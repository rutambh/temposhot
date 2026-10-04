import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class HardwareSensorGuardDialog extends StatelessWidget {
  final String sensorName;
  final String appName;
  final String description;

  const HardwareSensorGuardDialog({
    super.key,
    required this.sensorName,
    required this.appName,
    required this.description,
  });

  static Future<void> show({
    required BuildContext context,
    required String sensorName,
    required String appName,
    required String description,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: HardwareSensorGuardDialog(
          sensorName: sensorName,
          appName: appName,
          description: description,
        ),
      ),
    );
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.safetyOrange, width: 1.5),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.safetyOrange.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_off_rounded, color: AppColors.safetyOrange, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hardware Input Missing',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.safetyOrange.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Required: $sensorName',
              style: const TextStyle(
                color: AppColors.safetyOrange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 14),
          const Text(
            'Because audio input hardware/permission is unavailable, TempoShot cannot detect gunshots or dry-fire hammer drops.',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.safetyOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _exitApp,
            icon: const Icon(Icons.exit_to_app_rounded),
            label: const Text('Exit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
