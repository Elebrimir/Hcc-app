import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/pages/team_page.dart';
import 'package:hcc_app/models/team_model.dart';

void main() {
  testWidgets('TeamDisplayItem displays team info correctly', (
    WidgetTester tester,
  ) async {
    final team = TeamModel(
      name: 'Senior A',
      games: 10,
      win: 7,
      draw: 1,
      lose: 2,
      goals: 30,
      goalsAgainst: 15,
      goalDifference: 15,
      points: 22,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TeamDisplayItem(team: team))),
    );

    expect(find.text('Senior A'), findsOneWidget);
    expect(find.text('S'), findsOneWidget); // Initial
    expect(find.text('10'), findsOneWidget); // PJ
    expect(find.text('7'), findsOneWidget); // PG
    expect(find.text('15'), findsNWidgets(2)); // GF and DG
  });

  testWidgets('TeamDisplayItem handles null stats gracefully', (
    WidgetTester tester,
  ) async {
    final team = TeamModel(name: 'Junior B');

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TeamDisplayItem(team: team))),
    );

    expect(find.text('Junior B'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(7)); // All stats should be 0
  });
}
