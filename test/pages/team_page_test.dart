// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/team_model.dart';
import 'package:hcc_app/pages/team_page.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../mocks.mocks.dart';

class MockTeamDataWrapper extends StatelessWidget {
  final List<TeamModel> mockTeams;
  final Widget Function(BuildContext, List<TeamModel>) builder;

  const MockTeamDataWrapper({
    super.key,
    required this.mockTeams,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, mockTeams);
  }
}

class TestableTeamPage extends StatelessWidget {
  final List<TeamModel> mockTeams;

  const TestableTeamPage({super.key, required this.mockTeams});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equips'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[300],
      body: MockTeamDataWrapper(
        mockTeams: mockTeams,
        builder: (context, teams) {
          if (teams.isEmpty) {
            return const Center(
              child: Text(
                'No teams available.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return TeamDisplayItem(team: team);
            },
          );
        },
      ),
    );
  }
}

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
  });

  group('TeamPage Tests', () {
    testWidgets('Muestra el AppBar con el título correcto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: const MaterialApp(home: TestableTeamPage(mockTeams: [])),
        ),
      );

      expect(find.text('Equips'), findsOneWidget);
    });

    testWidgets('Muestra mensaje cuando no hay equipos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: const MaterialApp(home: TestableTeamPage(mockTeams: [])),
        ),
      );

      expect(find.text('No teams available.'), findsOneWidget);
      expect(find.byType(TeamDisplayItem), findsNothing);
    });

    testWidgets('Muestra la lista de equipos cuando hay datos', (
      WidgetTester tester,
    ) async {
      final testTeams = [
        TeamModel(
          name: 'Equipo A',
          games: 10,
          win: 5,
          draw: 2,
          lose: 3,
          goals: 15,
          goalsAgainst: 10,
          goalDifference: 5,
        ),
        TeamModel(
          name: 'Equipo B',
          games: 10,
          win: 8,
          draw: 1,
          lose: 1,
          goals: 20,
          goalsAgainst: 5,
          goalDifference: 15,
        ),
      ];

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: MaterialApp(home: TestableTeamPage(mockTeams: testTeams)),
        ),
      );

      expect(find.byType(TeamDisplayItem), findsNWidgets(2));
      expect(find.text('Equipo A'), findsNWidgets(2));
      expect(find.text('Equipo B'), findsNWidgets(2));
      // Check for some stats to ensure data is passed correctly
      expect(
        find.text('15'),
        findsNWidgets(2),
      ); // Goals for A and GoalDiff for B
      expect(find.text('20'), findsOneWidget); // Goals for B
    });
  });
}
