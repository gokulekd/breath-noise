import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breath_noise/main.dart';

void main() {
  testWidgets('Breath Noise splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BreathNoiseApp()));
    expect(find.text('BREATH NOISE'), findsOneWidget);
    expect(find.text('SOUNDS'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });
}
