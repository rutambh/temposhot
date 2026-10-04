import 'package:flutter/material.dart';
import '../../theme/field_notebook_theme.dart';

/// The chassis the timer sits in. Style 9 treats it as a clipboard, not a
/// plastic housing: paper surface, hairline edge, one soft shadow, and
/// registration bolts in the corners to keep the printed-page character.
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
    final tokens = FieldNotebookTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: tokens.brightness == Brightness.dark
                ? const Color(0xFF000000).withValues(alpha: 0.34)
                : const Color(0xFF2A2A1A).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
          const Positioned(top: 7, left: 7, child: _RegistrationBolt()),
          const Positioned(top: 7, right: 7, child: _RegistrationBolt()),
          const Positioned(bottom: 7, left: 7, child: _RegistrationBolt()),
          const Positioned(bottom: 7, right: 7, child: _RegistrationBolt()),
        ],
      ),
    );
  }
}

class _RegistrationBolt extends StatelessWidget {
  const _RegistrationBolt();

  @override
  Widget build(BuildContext context) {
    final tokens = FieldNotebookTheme.of(context);
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tokens.border,
      ),
    );
  }
}