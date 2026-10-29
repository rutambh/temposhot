import 'package:flutter/material.dart';
import '../../core/theme/ballistic_theme.dart';

/// Responsive scaffold container ensuring full adaptability from 320dp small phones
/// to tablets and desktop browser test environments.
///
/// On wide windows (> 540dp), constrains the layout to an authentic mobile chassis frame
/// so desktop web testing matches the physical Android screen.
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = BallisticTokens.of(context);
    final bg = backgroundColor ?? tokens.background;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 540;

        Widget content = Scaffold(
          backgroundColor: bg,
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          body: SafeArea(
            child: body,
          ),
        );

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: tokens.isDark ? const Color(0xFF0C0D0D) : const Color(0xFFD6D0C2),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 440,
                  maxHeight: 920,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: tokens.borderStrong, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        offset: const Offset(0, 10),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: content,
                ),
              ),
            ),
          );
        }

        return content;
      },
    );
  }
}
