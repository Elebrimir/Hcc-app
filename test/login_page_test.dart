import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/pages/login_page.dart';

/// A wrapper to provide a valid homePageContext for LoginPage.
class LoginPageTestWrapper extends StatelessWidget {
  const LoginPageTestWrapper({Key? key}) : super(key: key);

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

      // Tap the login button ("Acceder") without entering any text.
      final loginButton = find.widgetWithText(ElevatedButton, 'Acceder');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Expect validation error messages.
      expect(find.text('Por favor, introduce un email'), findsWidgets);
      expect(find.text('Por favor, introduce una contraseña'), findsOneWidget);
    });

    testWidgets(
      'Shows validation error for empty email when tapping forgot password',
      (WidgetTester tester) async {
        await tester.pumpWidget(const LoginPageTestWrapper());

        // Tap the "¿Olvidaste la contraseña?" button.
        final forgotPasswordButton = find.widgetWithText(
          TextButton,
          '¿Olvidaste la contraseña?',
        );
        expect(forgotPasswordButton, findsOneWidget);
        await tester.tap(forgotPasswordButton);
        await tester.pump(); // Allow Snackbar to appear

        // Expect a SnackBar with the error message.
        expect(find.text('Por favor, introduce un email'), findsOneWidget);
      },
    );

    testWidgets(
      'Shows validation error for empty password when only an email is entered',
      (WidgetTester tester) async {
        await tester.pumpWidget(const LoginPageTestWrapper());

        // Enter a valid email.
        final emailField = find.widgetWithText(TextFormField, 'Email');
        expect(emailField, findsOneWidget);
        await tester.enterText(emailField, 'test@example.com');

        // Tap the login button ("Acceder").
        final loginButton = find.widgetWithText(ElevatedButton, 'Acceder');
        expect(loginButton, findsOneWidget);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Only password validation should fail.
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

        // Enter text in password field.
        final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
        expect(passwordField, findsOneWidget);
        await tester.enterText(passwordField, 'dummyPassword');

        // Tap the login button ("Acceder").
        final loginButton = find.widgetWithText(ElevatedButton, 'Acceder');
        expect(loginButton, findsOneWidget);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Only email validation should fail.
        expect(find.text('Por favor, introduce un email'), findsOneWidget);
        expect(find.text('Por favor, introduce una contraseña'), findsNothing);
      },
    );
  });
}
