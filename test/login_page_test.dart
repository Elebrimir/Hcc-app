// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/widgets/login_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class LoginPageTestWrapper extends StatelessWidget {
  // ignore: use_super_parameters
  const LoginPageTestWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder:
            (scaffoldContext) =>
                Scaffold(body: LoginPage(homePageContext: scaffoldContext)),
      ),
    );
  }
}

void main() {
  group('LoginPage widget tests', () {
    testWidgets('Shows validation error for empty email on login button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LoginPageTestWrapper());

      final loginButton = find.widgetWithText(ElevatedButton, 'Acceder');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, introduce un email'), findsWidgets);
      expect(find.text('Por favor, introduce una contraseña'), findsOneWidget);
    });

    testWidgets(
      'Shows validation error for empty email when tapping forgot password',
      (WidgetTester tester) async {
        await tester.pumpWidget(const LoginPageTestWrapper());

        final forgotPasswordButton = find.widgetWithText(
          TextButton,
          '¿Olvidaste la contraseña?',
        );
        expect(forgotPasswordButton, findsOneWidget);
        await tester.tap(forgotPasswordButton);
        await tester.pump();

        expect(find.text('Por favor, introduce un email'), findsOneWidget);
      },
    );

    testWidgets(
      'Shows validation error for empty password when only an email is entered',
      (WidgetTester tester) async {
        await tester.pumpWidget(const LoginPageTestWrapper());

        final emailField = find.widgetWithText(TextFormField, 'Email');
        expect(emailField, findsOneWidget);
        await tester.enterText(emailField, 'test@example.com');

        final loginButton = find.widgetWithText(ElevatedButton, 'Acceder');
        expect(loginButton, findsOneWidget);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Por favor, introduce una contraseña'),
          findsOneWidget,
        );
        expect(find.text('Por favor, introduce un email'), findsNothing);
      },
    );

    testWidgets(
      'Shows validation error for empty email when only a password is entered',
      (WidgetTester tester) async {
        await tester.pumpWidget(const LoginPageTestWrapper());

        final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
        expect(passwordField, findsOneWidget);
        await tester.enterText(passwordField, 'dummyPassword');

        final loginButton = find.widgetWithText(ElevatedButton, 'Acceder');
        expect(loginButton, findsOneWidget);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(find.text('Por favor, introduce un email'), findsOneWidget);
        expect(find.text('Por favor, introduce una contraseña'), findsNothing);
      },
    );

    testWidgets('TextFields should hold their values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LoginPageTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Forgot password works with valid email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LoginPageTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Forgot password button is displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LoginPageTestWrapper());

      final forgotPasswordButton = find.widgetWithText(
        TextButton,
        '¿Olvidaste la contraseña?',
      );
      expect(forgotPasswordButton, findsOneWidget);
    });

    testWidgets('Form submits with valid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(const LoginPageTestWrapper());

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      expect(find.text('Por favor, introduce un email'), findsNothing);
      expect(find.text('Por favor, introduce una contraseña'), findsNothing);

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      final loginButton = find.widgetWithText(ElevatedButton, 'Acceder');
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Login page displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const LoginPageTestWrapper());

      expect(find.text('Acceso'), findsOneWidget);

      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Acceder'), findsOneWidget);
      expect(
        find.widgetWithText(TextButton, '¿Olvidaste la contraseña?'),
        findsOneWidget,
      );
    });
  });
}
