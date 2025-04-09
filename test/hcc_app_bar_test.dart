import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements auth.User {
  @override
  final String? email;

  MockUser({this.email});
}

class MockFirebaseAuth extends Mock implements auth.FirebaseAuth {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

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
      tester,
    ) async {
      await tester.pumpWidget(
        TestScaffold(appBar: HccAppBar(user: null, isDashboard: false)),
      );

      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsNothing);
    });

    testWidgets('should render dashboard AppBar when isDashboard is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestScaffold(
          appBar: HccAppBar(
            user: null,
            isDashboard: true,
            formattedDate: 'Dimecres, 1 de Març de 2023',
          ),
        ),
      );

      expect(find.text('Dimecres, 1 de Març de 2023'), findsOneWidget);
      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
    });

    testWidgets(
      'should display user email when user is provided but no userName',
      (tester) async {
        final mockUser = MockUser(email: 'test@example.com');

        await tester.pumpWidget(
          TestScaffold(appBar: HccAppBar(user: mockUser, isDashboard: true)),
        );

        expect(find.text('Hola test@example.com'), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);
      },
    );

    testWidgets('should display userName when provided', (tester) async {
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

      expect(find.text('Hola John Doe'), findsOneWidget);
    });

    testWidgets('should display welcome message with email in regular mode', (
      tester,
    ) async {
      final mockUser = MockUser(email: 'test@example.com');

      await tester.pumpWidget(
        TestScaffold(appBar: HccAppBar(user: mockUser, isDashboard: false)),
      );

      expect(find.text('Bienvenido test@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('should have correct preferred size based on isDashboard', (
      tester,
    ) async {
      final regularAppBar = HccAppBar(user: null, isDashboard: false);
      expect(regularAppBar.preferredSize.height, kToolbarHeight);

      final dashboardAppBar = HccAppBar(user: null, isDashboard: true);
      expect(dashboardAppBar.preferredSize.height, 120.0);
    });

    testWidgets('should call onNavigate when _onSignOut is called', (
      tester,
    ) async {
      final mockUser = MockUser(email: 'test@example.com');
      bool navigateCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TestScaffold(
            appBar: HccAppBar(
              user: mockUser,
              isDashboard: false,
              onNavigate: (_) {
                navigateCalled = true; // Marca como llamada
              },
            ),
          ),
        ),
      );

      // Simula el tap en el botón de logout
      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();

      // Verifica que la función de navegación fue llamada
      expect(navigateCalled, true);
    });
  });
}
