import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/user_provider.dart';

class MockUser extends Mock implements auth.User {
  @override
  final String? email;

  MockUser({this.email});
}

class MockFirebaseAuth extends Mock implements auth.FirebaseAuth {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserProvider extends Mock implements UserProvider {}

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
    late MockUser mockUser;
    late MockUserProvider mockUserProvider;

    setUp(() {
      mockUser = MockUser(email: 'test@example.com');
      mockUserProvider = MockUserProvider();

      // Configuramos el comportamiento del mock del UserProvider
      when(mockUserProvider.firebaseUser).thenReturn(mockUser);
      when(mockUserProvider.userModel).thenReturn(null);
    });

    Widget createTestWidget(HccAppBar appBar) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ],
        child: MaterialApp(home: TestScaffold(appBar: appBar)),
      );
    }

    testWidgets('should render regular AppBar when isDashboard is false', (
      tester,
    ) async {
      // Configuramos el mock para que firebaseUser sea null
      when(mockUserProvider.firebaseUser).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(HccAppBar(user: null, isDashboard: false)),
      );

      // Verificamos que el texto "Hoquei Club Cocentaina" esté presente
      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
      // Verificamos que el icono de logout no esté presente
      expect(find.byIcon(Icons.exit_to_app), findsNothing);
    });

    testWidgets('should render dashboard AppBar when isDashboard is true', (
      tester,
    ) async {
      // Configuramos el mock para que firebaseUser sea null
      when(mockUserProvider.firebaseUser).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(
          HccAppBar(
            user: null,
            isDashboard: true,
            formattedDate: 'Dimecres, 1 de Març de 2023',
          ),
        ),
      );

      // Verificamos que el texto "Hoquei Club Cocentaina" esté presente
      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
      // Verificamos que la fecha formateada esté presente
      expect(find.text('Dimecres, 1 de Març de 2023'), findsOneWidget);
    });

    testWidgets(
      'should display user email when user is provided but no userName',
      (tester) async {
        // Configuramos el mock para que firebaseUser devuelva un usuario
        when(mockUserProvider.firebaseUser).thenReturn(mockUser);

        await tester.pumpWidget(
          createTestWidget(HccAppBar(user: mockUser, isDashboard: true)),
        );

        // Verificamos que el texto "Hola test@example.com" esté presente
        expect(find.text('Hola test@example.com'), findsOneWidget);
        // Verificamos que el icono de logout esté presente
        expect(find.byIcon(Icons.logout), findsOneWidget);
      },
    );

    // testWidgets('should display userName when provided', (tester) async {
    //   // Configuramos el mock para que firebaseUser sea null
    //   when(mockUserProvider.firebaseUser).thenReturn(null);

    //   await tester.pumpWidget(
    //     createTestWidget(
    //       HccAppBar(user: null, userName: 'John Doe', isDashboard: true),
    //     ),
    //   );

    //   // Verificamos que el texto "Hola John Doe" esté presente
    //   expect(find.text('Hola John Doe'), findsOneWidget);
    // });

    testWidgets('should display welcome message with email in regular mode', (
      tester,
    ) async {
      when(mockUserProvider.firebaseUser).thenReturn(mockUser);

      await tester.pumpWidget(
        createTestWidget(HccAppBar(user: mockUser, isDashboard: false)),
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

    // testWidgets('should call onNavigate when _onSignOut is called', (
    //   tester,
    // ) async {
    //   bool navigateCalled = false;

    //   await tester.pumpWidget(
    //     createTestWidget(
    //       HccAppBar(
    //         user: mockUser,
    //         isDashboard: false,
    //         onNavigate: (_) {
    //           navigateCalled = true;
    //         },
    //       ),
    //     ),
    //   );

    //   await tester.tap(find.byIcon(Icons.exit_to_app));
    //   await tester.pumpAndSettle();

    //   expect(navigateCalled, true);
    // });

    // testWidgets('should display default message when userModel is null', (
    //   tester,
    // ) async {
    //   await tester.pumpWidget(
    //     createTestWidget(HccAppBar(user: null, isDashboard: false)),
    //   );

    //   expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
    // });

    // testWidgets('should call onSignOut when logout button is pressed', (
    //   tester,
    // ) async {
    //   bool signOutCalled = false;

    //   await tester.pumpWidget(
    //     createTestWidget(
    //       HccAppBar(
    //         user: mockUser,
    //         isDashboard: false,
    //         onSignOut: () {
    //           signOutCalled = true;
    //         },
    //       ),
    //     ),
    //   );

    //   await tester.tap(find.byIcon(Icons.exit_to_app));
    //   await tester.pumpAndSettle();

    //   expect(signOutCalled, true);
    // });

    // testWidgets('should render logo in dashboard mode', (tester) async {
    //   await tester.pumpWidget(
    //     createTestWidget(HccAppBar(user: null, isDashboard: true)),
    //   );

    //   expect(find.byType(Image), findsOneWidget);
    //   expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
    // });

    // testWidgets('should display userModel name when available', (tester) async {
    //   when(mockUserProvider.userModel).thenReturn(null);

    //   await tester.pumpWidget(
    //     createTestWidget(
    //       HccAppBar(user: mockUser, isDashboard: true, userName: 'Carlos'),
    //     ),
    //   );

    //   expect(find.text('Hola Carlos'), findsOneWidget);
    // });

    testWidgets('should display email when userName is null', (tester) async {
      when(mockUserProvider.firebaseUser).thenReturn(mockUser);

      await tester.pumpWidget(
        createTestWidget(HccAppBar(user: mockUser, isDashboard: true)),
      );

      expect(find.text('Hola test@example.com'), findsOneWidget);
    });
  });
}
