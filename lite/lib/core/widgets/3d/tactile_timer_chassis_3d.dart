import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TactileTimerChassis3D extends StatelessWidget {
  final Widget child;
  final double padding;

  const TactileTimerChassis3D({
    super.key,
    required this.child,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blackCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.olive.withAlpha(90),
          width: 2.0,
        ),
        boxShadow: [
          // Deep Ground 3D Shadow
          BoxShadow(
            color: Colors.black.withAlpha(240),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          // Top-Light Specular Highlight
          BoxShadow(
            color: Colors.white.withAlpha(18),
            blurRadius: 2,
            offset: const Offset(0, -1.5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main Body Padding
          Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
          // 4 Corner Tactile Hex Bolts for Skeuomorphic Rugged Look
          const Positioned(top: 10, left: 10, child: _HexBolt()),
          const Positioned(top: 10, right: 10, child: _HexBolt()),
          const Positioned(bottom: 10, left: 10, child: _HexBolt()),
          const Positioned(bottom: 10, right: 10, child: _HexBolt()),
        ],
      ),
    );
  }
}

class _HexBolt extends StatelessWidget {
  const _HexBolt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.steelDark,
        border: Border.all(color: AppColors.steel.withAlpha(120), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(180),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
