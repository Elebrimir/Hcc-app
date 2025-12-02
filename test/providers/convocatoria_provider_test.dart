import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ConvocatoriaProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    provider = ConvocatoriaProvider(firestore: fakeFirestore);
  });

  group('ConvocatoriaProvider Tests', () {
    final event = Event(
      id: 'event1',
      title: 'Match',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      confirmedUsers: [],
    );

    final player = ConvokedUser(
      userId: 'user1',
      name: 'Player 1',
      role: 'player',
    );

    test(
      'createConvocatoria should add event and convocatoria to Firestore',
      () async {
        await provider.createConvocatoria(
          teamId: 'team1',
          teamName: 'Team A',
          event: event,
          players: [player],
          delegates: [],
        );

        final eventsSnapshot = await fakeFirestore.collection('events').get();
        expect(eventsSnapshot.docs.length, 1);
        expect(eventsSnapshot.docs.first.data()['title'], 'Match');

        final convSnapshot =
            await fakeFirestore.collection('convocatorias').get();
        expect(convSnapshot.docs.length, 1);
        expect(convSnapshot.docs.first.data()['teamName'], 'Team A');
        expect(
          convSnapshot.docs.first.data()['eventId'],
          eventsSnapshot.docs.first.id,
        );

        expect(provider.convocatorias.length, 1);
      },
    );

    test('fetchConvocatorias should populate list', () async {
      await fakeFirestore.collection('convocatorias').add({
        'teamId': 'team1',
        'teamName': 'Team A',
        'eventId': 'event1',
        'createdAt': DateTime.now(),
        'players': [],
        'delegates': [],
      });

      await provider.fetchConvocatorias();

      expect(provider.convocatorias.length, 1);
      expect(provider.convocatorias.first.teamName, 'Team A');
    });

    test('updateConvocationStatus should update user status', () async {
      // Add initial data
      final docRef = await fakeFirestore.collection('convocatorias').add({
        'teamId': 'team1',
        'teamName': 'Team A',
        'eventId': 'event1',
        'createdAt': DateTime.now(),
        'players': [
          {
            'userId': 'user1',
            'name': 'Player 1',
            'role': 'player',
            'status': 'pending',
          },
        ],
        'delegates': [],
      });

      // Update status
      await provider.updateConvocationStatus(
        docRef.id,
        'user1',
        ConvocationStatus.confirmed,
      );

      // Verify in Firestore
      final snapshot = await docRef.get();
      final players = snapshot.data()!['players'] as List;
      expect(players[0]['status'], 'confirmed');

      // Verify locally (fetchConvocatorias is called inside updateConvocationStatus)
      expect(provider.convocatorias.length, 1);
      expect(
        provider.convocatorias.first.players.first.status,
        ConvocationStatus.confirmed,
      );
    });
  });
}
