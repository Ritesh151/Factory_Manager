import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smarterp/main.dart';

void main() {
  testWidgets('SmartERP app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartErpApp());

    // Verify that the app renders
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
