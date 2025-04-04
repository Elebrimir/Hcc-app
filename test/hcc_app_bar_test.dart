import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {
  @override
  final String? email;

  MockUser({this.email});
}

// Widget de prueba para envolver nuestro HccAppBar
class TestScaffold extends StatelessWidget {
  final HccAppBar appBar;

  const TestScaffold({super.key, required this.appBar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        body: const Center(child: Text('Test Content')),
      ),
    );
  }
}

void main() {
  group('HccAppBar Widget Tests', () {
    testWidgets('should render regular AppBar when isDashboard is false', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestScaffold(appBar: HccAppBar(isDashboard: false, user: null)),
      );

      // Verify that the title is shown correctly
      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);

      // Verify that the logout button is not shown when no user is provided
      expect(find.byIcon(Icons.exit_to_app), findsNothing);
    });

    testWidgets('should render dashboard AppBar when isDashboard is true', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        TestScaffold(
          appBar: HccAppBar(
            isDashboard: true,
            formattedDate: 'Dimecres, 1 de Març de 2023',
            user: null,
          ),
        ),
      );

      // Verify that the date is shown
      expect(find.text('Dimecres, 1 de Març de 2023'), findsOneWidget);

      // Verify title
      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);

      // Note: Asset image won't load in test environment, but we can check if the structure is there
      // In production code, we'll need to add error handlers for Image.asset in tests
    });

    testWidgets(
      'should display user email when user is provided but no userName',
      (WidgetTester tester) async {
        final mockUser = MockUser(email: 'test@example.com');

        await tester.pumpWidget(
          TestScaffold(appBar: HccAppBar(user: mockUser, isDashboard: true)),
        );

        // Verify that the user email is displayed with greeting
        expect(find.text('Hola test@example.com'), findsOneWidget);

        // Verify that logout button is shown
        expect(find.byIcon(Icons.logout), findsOneWidget);
      },
    );

    testWidgets('should display userName when provided', (
      WidgetTester tester,
    ) async {
      final mockUser = MockUser(email: 'test@example.com');

      await tester.pumpWidget(
        TestScaffold(
          appBar: HccAppBar(
            user: mockUser,
            userName: 'John Doe',
            isDashboard: true,
          ),
        ),
      );

      // Verify that the user name is displayed with greeting
      expect(find.text('Hola John Doe'), findsOneWidget);
    });

    testWidgets('should display welcome message with email in regular mode', (
      WidgetTester tester,
    ) async {
      final mockUser = MockUser(email: 'test@example.com');

      await tester.pumpWidget(
        TestScaffold(appBar: HccAppBar(user: mockUser, isDashboard: false)),
      );

      // Verify welcome message
      expect(find.text('Bienvenido test@example.com'), findsOneWidget);

      // Verify logout button
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('should have correct preferred size based on isDashboard', (
      WidgetTester tester,
    ) async {
      // Test regular app bar height
      final regularAppBar = HccAppBar(isDashboard: false, user: null);
      expect(regularAppBar.preferredSize.height, kToolbarHeight);

      // Test dashboard app bar height
      final dashboardAppBar = HccAppBar(isDashboard: true, user: null);
      expect(dashboardAppBar.preferredSize.height, 120.0);
    });
  });
}
