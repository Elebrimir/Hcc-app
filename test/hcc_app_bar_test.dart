// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

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
      when(mockUserProvider.firebaseUser).thenReturn(null);

      await tester.pumpWidget(
        createTestWidget(HccAppBar(user: null, isDashboard: false)),
      );

      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsNothing);
    });

    testWidgets('should render dashboard AppBar when isDashboard is true', (
      tester,
    ) async {
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

      expect(find.text('Hoquei Club Cocentaina'), findsOneWidget);
      expect(find.text('Dimecres, 1 de Març de 2023'), findsOneWidget);
    });

    testWidgets(
      'should display user email when user is provided but no userName',
      (tester) async {
        when(mockUserProvider.firebaseUser).thenReturn(mockUser);

        await tester.pumpWidget(
          createTestWidget(HccAppBar(user: mockUser, isDashboard: true)),
        );

        expect(find.text('Hola test@example.com'), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);
      },
    );

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

    testWidgets('should display email when userName is null', (tester) async {
      when(mockUserProvider.firebaseUser).thenReturn(mockUser);

      await tester.pumpWidget(
        createTestWidget(HccAppBar(user: mockUser, isDashboard: true)),
      );

      expect(find.text('Hola test@example.com'), findsOneWidget);
    });
  });
}
