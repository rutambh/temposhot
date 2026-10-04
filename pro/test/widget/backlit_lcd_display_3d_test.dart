import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot_pro/core/widgets/3d/backlit_lcd_display_3d.dart';

void main() {
  testWidgets('BacklitLcdDisplay3D renders 3D formatted digits and splits', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BacklitLcdDisplay3D(
            timeSec: 3.45,
            shotCount: 6,
            lastSplitSec: 0.22,
            isArmed: false,
            isRunning: true,
          ),
        ),
      ),
    );

    expect(find.byType(BacklitLcdDisplay3D), findsOneWidget);
    expect(find.text('03.45'), findsOneWidget);
    expect(find.text('SHOTS: 6'), findsOneWidget);
    expect(find.text('SPLIT: +0.22s'), findsOneWidget);
  });
}
