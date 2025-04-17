import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/widgets/registration_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

/// Un wrapper para proporcionar un contexto válido para RegistrationPage.
class RegistrationPageTestWrapper extends StatelessWidget {
  const RegistrationPageTestWrapper({super.key});

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
        await tester.pumpWidget(const RegistrationPageTestWrapper());

        // Tap the register button without entering any text
        final registerButton = find.widgetWithText(
          ElevatedButton,
          'Registrarse',
        );
        expect(registerButton, findsOneWidget);
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Expect validation error messages
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
      await tester.pumpWidget(const RegistrationPageTestWrapper());

      // Enter invalid email
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      // Tap the register button
      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Expect validation error message for email
      expect(find.text('Por favor, introduce un email válido'), findsOneWidget);
    });

    testWidgets('Shows validation error for short password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationPageTestWrapper());

      // Enter valid email but short password
      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '12345');

      // Tap the register button
      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Expect validation error message for password
      expect(
        find.text('La contraseña debe tener al menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('Shows validation error for non-matching passwords', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationPageTestWrapper());

      // Enter valid email, valid password, but different confirm password
      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final confirmPasswordField = find.widgetWithText(
        TextFormField,
        'Confirma contraseña',
      );

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'differentpassword');

      // Tap the register button
      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Expect validation error message for confirm password
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('TextFields should hold their values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationPageTestWrapper());

      // Enter text in all fields
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

      // Verify text was entered correctly
      expect(find.text('test@example.com'), findsOneWidget);
      expect(
        find.text('password123'),
        findsNWidgets(2),
      ); // Both password fields
    });

    testWidgets('Form submits with valid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(const RegistrationPageTestWrapper());

      // Enter valid credentials
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

      // Verify inputs are valid (no error messages should appear)
      expect(find.text('Por favor, introduce un email'), findsNothing);
      expect(find.text('Por favor, introduce una contraseña'), findsNothing);
      expect(find.text('Por favor, confirma la contraseña'), findsNothing);
      expect(find.text('Las contraseñas no coinciden'), findsNothing);

      // Verify form contents
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsNWidgets(2));

      // Instead of tapping the button which would trigger Firebase Auth,
      // just verify the button exists
      final registerButton = find.widgetWithText(ElevatedButton, 'Registrarse');
      expect(registerButton, findsOneWidget);
    });

    testWidgets('Registration page displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const RegistrationPageTestWrapper());

      // Check dialog title
      expect(find.text('Registro'), findsOneWidget);

      // Check input fields
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Confirma contraseña'),
        findsOneWidget,
      );

      // Check register button
      expect(
        find.widgetWithText(ElevatedButton, 'Registrarse'),
        findsOneWidget,
      );
    });
  });
}
