// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/widgets/registration_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class RegistrationWidgetTestWrapper extends StatelessWidget {
  const RegistrationWidgetTestWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder:
            (scaffoldContext) => Scaffold(
              body: RegistrationPage(homePageContext: scaffoldContext),
            ),
      ),
    );
  }
}

void main() {
  group('RegistrationPage widget tests', () {
    testWidgets(
      'Shows validation error for empty fields on register button tap',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RegistrationWidgetTestWrapper());

        final registerButton = find.widgetWithText(
          ElevatedButton,
          'Registrarse',
        );
        expect(registerButton, findsOneWidget);
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        expect(find.text('Por favor, introduce un email'), findsWidgets);
        expect(
          find.text('Por favor, introduce una contraseña'),
          findsOneWidget,
        );
        expect(find.text('Por favor, confirma la contraseña'), findsOneWidget);
      },
    );

    testWidgets('Shows validation error for invalid email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationWidgetTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, introduce un email válido'), findsOneWidget);
    });

    testWidgets('Shows validation error for short password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationWidgetTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '12345');

      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(
        find.text('La contraseña debe tener al menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('Shows validation error for non-matching passwords', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationWidgetTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final confirmPasswordField = find.widgetWithText(
        TextFormField,
        'Confirma contraseña',
      );

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'differentpassword');

      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('TextFields should hold their values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationWidgetTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final confirmPasswordField = find.widgetWithText(
        TextFormField,
        'Confirma contraseña',
      );

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'password123');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsNWidgets(2));
    });

    testWidgets('Form submits with valid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(const RegistrationWidgetTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final confirmPasswordField = find.widgetWithText(
        TextFormField,
        'Confirma contraseña',
      );

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'password123');
      await tester.pump();

      expect(find.text('Por favor, introduce un email'), findsNothing);
      expect(find.text('Por favor, introduce una contraseña'), findsNothing);
      expect(find.text('Por favor, confirma la contraseña'), findsNothing);
      expect(find.text('Las contraseñas no coinciden'), findsNothing);

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsNWidgets(2));

      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      expect(registerButton, findsOneWidget);
    });

    testWidgets('Registration page displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationWidgetTestWrapper());

      expect(find.text('Registro'), findsOneWidget);

      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Confirma contraseña'),
        findsOneWidget,
      );

      expect(
        find.widgetWithText(ElevatedButton, 'Registrarse'),
        findsOneWidget,
      );
    });
  });
}
