// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hcc_app/main.dart';

void main() {
  testWidgets('HCC App elements test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title appears in the app bar
    expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);

    // Verify that the "Notícies" button exists
    expect(find.text('Notícies'), findsOneWidget);

    // Verify that the footer text appears
    expect(find.text('HCC App'), findsOneWidget);

    // Test button press
    await tester.tap(find.widgetWithText(ElevatedButton, 'Notícies'));
    await tester.pump();

    // Verify the button was pressed (in a real app, you'd verify the
    // actual behavior triggered by the button)
  });
}
