// Copyright (c) 2026 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/player_provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/widgets/player_form_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockPlayerProvider extends Mock implements PlayerProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class MockUser extends Mock implements User {}

void main() {
  late MockPlayerProvider mockPlayerProvider;
  late MockUserProvider mockUserProvider;
  late MockUser mockFirebaseUser;

  setUp(() {
    mockPlayerProvider = MockPlayerProvider();
    mockUserProvider = MockUserProvider();
    mockFirebaseUser = MockUser();

    when(() => mockUserProvider.firebaseUser).thenReturn(mockFirebaseUser);
    when(() => mockFirebaseUser.uid).thenReturn('user123');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<PlayerProvider>.value(
              value: mockPlayerProvider,
            ),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: const PlayerFormModal(),
        ),
      ),
    );
  }

  group('PlayerFormModal Widget Tests', () {
    testWidgets('renders all fields and title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Afegir Jugador'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Nom del jugador/a'), findsOneWidget);
      expect(find.text('Categoria (ex: Escoleta, Prebenjamí)'), findsOneWidget);
      expect(find.text('AFEGIR JUGADOR'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('AFEGIR JUGADOR'));
      await tester.pump();

      expect(find.text('Si us plau, entra un nom'), findsOneWidget);
      expect(find.text('Si us plau, entra una categoria'), findsOneWidget);
    });

    testWidgets('calls addPlayer and closes when valid', (
      WidgetTester tester,
    ) async {
      when(
        () => mockPlayerProvider.addPlayer(any()),
      ).thenAnswer((_) async => 'new_player_id');

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nom del jugador/a'),
        'Pau Petit',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Categoria (ex: Escoleta, Prebenjamí)',
        ),
        'Escoleta',
      );

      await tester.tap(find.text('AFEGIR JUGADOR'));
      await tester.pump();

      verify(() => mockPlayerProvider.addPlayer(any())).called(1);
    });
  });
}
