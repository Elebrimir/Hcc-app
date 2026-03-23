import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/pages/convocatoria_details_page.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  testWidgets('ConvocatoriaDetailsPage displays convocatoria info correctly', (
    WidgetTester tester,
  ) async {
    final now = Timestamp.now();
    final convocatoria = ConvocatoriaModel(
      id: 'conv_1',
      teamId: 'team_1',
      teamName: 'Senior A',
      eventId: 'event_1',
      players: [
        ConvokedUser(
          userId: 'u1',
          name: 'Player 1',
          role: 'player',
          status: ConvocationStatus.confirmed,
        ),
        ConvokedUser(
          userId: 'u2',
          name: 'Player 2',
          role: 'player',
          status: ConvocationStatus.pending,
        ),
        ConvokedUser(
          userId: 'u3',
          name: 'Player 3',
          role: 'player',
          status: ConvocationStatus.declined,
        ),
      ],
      delegates: [
        ConvokedUser(
          userId: 'd1',
          name: 'Delegate 1',
          role: 'delegate',
          status: ConvocationStatus.confirmed,
        ),
      ],
      createdAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(home: ConvocatoriaDetailsPage(convocatoria: convocatoria)),
    );

    // Check header
    expect(find.text('Senior A'), findsOneWidget);
    expect(find.textContaining('Creat el:'), findsOneWidget);

    // Check sections
    expect(find.text('Jugadors (3)'), findsOneWidget);
    expect(find.text('Delegats (1)'), findsOneWidget);

    // Check users
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
    expect(find.text('Player 3'), findsOneWidget);
    expect(find.text('Delegate 1'), findsOneWidget);

    // Check statuses
    expect(find.text('CONFIRMED'), findsNWidgets(2));
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('DECLINED'), findsOneWidget);

    // Check icons (by looking for specific IconData if possible, or just verifying they exist)
    expect(find.byIcon(Icons.check), findsNWidgets(2));
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('ConvocatoriaDetailsPage handles empty lists gracefully', (
    WidgetTester tester,
  ) async {
    final now = Timestamp.now();
    final convocatoria = ConvocatoriaModel(
      id: 'conv_2',
      teamId: 'team_2',
      teamName: 'Junior B',
      eventId: 'event_2',
      players: [],
      delegates: [],
      createdAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(home: ConvocatoriaDetailsPage(convocatoria: convocatoria)),
    );

    expect(find.text('Jugadors (0)'), findsOneWidget);
    expect(find.text('Delegats (0)'), findsOneWidget);
    expect(find.text('No hi ha ningú assignat.'), findsNWidgets(2));
  });
}
