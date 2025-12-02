import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:mockito/mockito.dart';

// MockDocumentSnapshot for testing fromFirestore
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  @override
  final String id;

  MockDocumentSnapshot(this._data, this.id);

  @override
  Map<String, dynamic>? data() => _data;
}

void main() {
  group('ConvocatoriaModel Tests', () {
    final now = Timestamp.now();
    final player1 = ConvokedUser(
      userId: 'user1',
      name: 'Player One',
      role: 'player',
      status: ConvocationStatus.pending,
    );
    final delegate1 = ConvokedUser(
      userId: 'del1',
      name: 'Delegate One',
      role: 'delegate',
      status: ConvocationStatus.confirmed,
    );

    final convocatoria = ConvocatoriaModel(
      id: 'conv1',
      teamId: 'team1',
      teamName: 'Team A',
      eventId: 'event1',
      players: [player1],
      delegates: [delegate1],
      createdAt: now,
    );

    test('should create ConvocatoriaModel correctly', () {
      expect(convocatoria.id, 'conv1');
      expect(convocatoria.teamId, 'team1');
      expect(convocatoria.teamName, 'Team A');
      expect(convocatoria.eventId, 'event1');
      expect(convocatoria.players.length, 1);
      expect(convocatoria.delegates.length, 1);
      expect(convocatoria.createdAt, now);
    });

    test('should convert to Firestore map correctly', () {
      final map = convocatoria.toFirestore();

      expect(map['teamId'], 'team1');
      expect(map['teamName'], 'Team A');
      expect(map['eventId'], 'event1');
      expect(map['createdAt'], now);
      expect((map['players'] as List).length, 1);
      expect((map['delegates'] as List).length, 1);

      final playerMap = (map['players'] as List)[0] as Map<String, dynamic>;
      expect(playerMap['userId'], 'user1');
      expect(playerMap['status'], 'pending');
    });

    test('should create from Firestore snapshot correctly', () {
      final data = {
        'teamId': 'team1',
        'teamName': 'Team A',
        'eventId': 'event1',
        'createdAt': now,
        'players': [
          {
            'userId': 'user1',
            'name': 'Player One',
            'role': 'player',
            'status': 'pending',
          },
        ],
        'delegates': [
          {
            'userId': 'del1',
            'name': 'Delegate One',
            'role': 'delegate',
            'status': 'confirmed',
          },
        ],
      };

      final snapshot = MockDocumentSnapshot(data, 'conv1');
      final model = ConvocatoriaModel.fromFirestore(snapshot);

      expect(model.id, 'conv1');
      expect(model.teamId, 'team1');
      expect(model.players.first.userId, 'user1');
      expect(model.players.first.status, ConvocationStatus.pending);
      expect(model.delegates.first.userId, 'del1');
      expect(model.delegates.first.status, ConvocationStatus.confirmed);
    });
  });

  group('ConvokedUser Tests', () {
    test('should copyWith correctly', () {
      final user = ConvokedUser(
        userId: 'u1',
        name: 'Name',
        role: 'player',
        status: ConvocationStatus.pending,
      );

      final updated = user.copyWith(status: ConvocationStatus.confirmed);

      expect(updated.userId, 'u1');
      expect(updated.status, ConvocationStatus.confirmed);
    });

    test('should parse status from string correctly', () {
      final map = {
        'userId': 'u1',
        'name': 'Name',
        'role': 'player',
        'status': 'declined',
      };
      final user = ConvokedUser.fromMap(map);
      expect(user.status, ConvocationStatus.declined);
    });

    test('should default to pending for unknown status', () {
      final map = {
        'userId': 'u1',
        'name': 'Name',
        'role': 'player',
        'status': 'unknown_status',
      };
      final user = ConvokedUser.fromMap(map);
      expect(user.status, ConvocationStatus.pending);
    });
  });
}
