// Copyright (c) 2026 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/team_provider.dart';
import 'package:hcc_app/widgets/team_form_modal.dart';

class MockTeamProvider extends Mock implements TeamProvider {}

void main() {
  late MockTeamProvider mockTeamProvider;

  setUp(() {
    mockTeamProvider = MockTeamProvider();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<TeamProvider>.value(
          value: mockTeamProvider,
          child: const TeamFormModal(),
        ),
      ),
    );
  }

  group('TeamFormModal Widget Tests', () {
    testWidgets('renders all fields and title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Crear Nou Equip'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Nom de l\'equip'), findsOneWidget);
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Temporada (any)'), findsOneWidget);
      expect(find.text('CREAR EQUIP'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('CREAR EQUIP'));
      await tester.pump();

      expect(find.text('Si us plau, entra un nom'), findsOneWidget);
      expect(find.text('Si us plau, entra una categoria'), findsOneWidget);
    });

    testWidgets('calls addTeam and closes when valid', (
      WidgetTester tester,
    ) async {
      when(
        () => mockTeamProvider.addTeam(any()),
      ).thenAnswer((_) async => 'new_id');

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nom de l\'equip'),
        'Senior A',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Categoria'),
        'Sènior',
      );

      await tester.tap(find.text('CREAR EQUIP'));
      await tester.pump();

      verify(() => mockTeamProvider.addTeam(any())).called(1);
    });
  });
}
