// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/team_model.dart'; // Import TeamModel
import 'package:hcc_app/models/user_model.dart'; // Keep UserModel for nested lists
import 'package:mockito/mockito.dart';

// TestDocumentSnapshot remains the same as it's generic
class TestDocumentSnapshot {
  final Map<String, dynamic> _data;

  TestDocumentSnapshot(this._data);

  Map<String, dynamic> data() => _data;
}

// Remove UserModelTestExtension or adapt if needed for TeamModel specific test helpers

// MockDocumentSnapshot remains the same as it's generic
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  Map<String, dynamic>? data() => _data;
}

void main() {
  group('TeamModel tests', () {
    // Update group description
    // Sample UserModels for testing lists
    final testPlayer = UserModel(
      email: 'player@example.com',
      name: 'Player',
      lastname: 'One',
      role: 'player',
    );
    final testCoach = UserModel(
      email: 'coach@example.com',
      name: 'Coach',
      lastname: 'One',
      role: 'coach',
    );
    final testDelegate = UserModel(
      email: 'delegate@example.com',
      name: 'Delegate',
      lastname: 'One',
      role: 'delegate',
    );

    test('should create a TeamModel from constructor', () {
      final timestamp = Timestamp.now();
      final model = TeamModel(
        name: 'Test Team',
        category: 'Senior',
        image: 'team_image.jpg',
        season: 2024,
        points: 10,
        win: 3,
        lose: 1,
        draw: 1,
        goals: 15,
        goalsAgainst: 5,
        goalDifference: 10,
        games: 5,
        players: [testPlayer],
        coaches: [testCoach],
        delegates: [testDelegate],
        createdAt: timestamp,
      );

      expect(model.name, 'Test Team');
      expect(model.category, 'Senior');
      expect(model.image, 'team_image.jpg');
      expect(model.season, 2024);
      expect(model.points, 10);
      expect(model.win, 3);
      expect(model.lose, 1);
      expect(model.draw, 1);
      expect(model.goals, 15);
      expect(model.goalsAgainst, 5);
      expect(model.goalDifference, 10);
      expect(model.games, 5);
      expect(model.players?.length, 1);
      expect(model.players?.first.email, 'player@example.com');
      expect(model.coaches?.length, 1);
      expect(model.coaches?.first.email, 'coach@example.com');
      expect(model.delegates?.length, 1);
      expect(model.delegates?.first.email, 'delegate@example.com');
      expect(model.createdAt, timestamp);
    });

    test('should create a TeamModel from Firestore snapshot', () {
      final timestamp = Timestamp.now();
      final data = {
        'name': 'Test Team',
        'category': 'Senior',
        'image': 'team_image.jpg',
        'season': 2024,
        'points': 10,
        'win': 3,
        'lose': 1,
        'draw': 1,
        'goals': 15,
        'goals_against': 5,
        'goal_difference': 10,
        'games': 5,
        'players': [
          {
            'email': 'player@example.com',
            'name': 'Player',
            'lastname': 'One',
            'role': 'player',
            'created_at':
                timestamp, // Firestore might store timestamps for users too
          },
        ],
        'coaches': [
          {
            'email': 'coach@example.com',
            'name': 'Coach',
            'lastname': 'One',
            'role': 'coach',
            'created_at': timestamp,
          },
        ],
        'delegates': [
          {
            'email': 'delegate@example.com',
            'name': 'Delegate',
            'lastname': 'One',
            'role': 'delegate',
            'created_at': timestamp,
          },
        ],
        'created_at': timestamp,
      };

      final mockSnapshot = MockDocumentSnapshot(data);
      final model = TeamModel.fromFirestore(mockSnapshot, null);

      expect(model.name, 'Test Team');
      expect(model.category, 'Senior');
      expect(model.image, 'team_image.jpg');
      expect(model.season, 2024);
      expect(model.points, 10);
      expect(model.win, 3);
      expect(model.lose, 1);
      expect(model.draw, 1);
      expect(model.goals, 15);
      expect(model.goalsAgainst, 5);
      expect(model.goalDifference, 10);
      expect(model.games, 5);
      expect(model.players?.length, 1);
      expect(model.players?.first.email, 'player@example.com');
      expect(model.coaches?.length, 1);
      expect(model.coaches?.first.email, 'coach@example.com');
      expect(model.delegates?.length, 1);
      expect(model.delegates?.first.email, 'delegate@example.com');
      expect(model.createdAt, timestamp);
    });

    test('should convert TeamModel to Firestore data', () {
      final model = TeamModel(
        name: 'Test Team',
        category: 'Senior',
        image: 'team_image.jpg',
        season: 2024,
        points: 10,
        win: 3,
        lose: 1,
        draw: 1,
        goals: 15,
        goalsAgainst: 5,
        goalDifference: 10,
        games: 5,
        players: [testPlayer],
        coaches: [testCoach],
        delegates: [testDelegate],
        // createdAt is handled by FieldValue.serverTimestamp() in toFirestore
      );

      final data = model.toFirestore();

      expect(data['name'], 'Test Team');
      expect(data['category'], 'Senior');
      expect(data['image'], 'team_image.jpg');
      expect(data['season'], 2024);
      expect(data['points'], 10);
      expect(data['win'], 3);
      expect(data['lose'], 1);
      expect(data['draw'], 1);
      expect(data['goals'], 15);
      expect(data['goals_against'], 5);
      expect(data['goal_difference'], 10);
      expect(data['games'], 5);
      expect(data['players'], isA<List>());
      expect((data['players'] as List).length, 1);
      expect((data['players'] as List).first['email'], 'player@example.com');
      expect(data['coaches'], isA<List>());
      expect((data['coaches'] as List).length, 1);
      expect((data['coaches'] as List).first['email'], 'coach@example.com');
      expect(data['delegates'], isA<List>());
      expect((data['delegates'] as List).length, 1);
      expect(
        (data['delegates'] as List).first['email'],
        'delegate@example.com',
      );
      expect(data['created_at'], FieldValue.serverTimestamp());
    });

    test('should handle null values in fromFirestore', () {
      // Use MockDocumentSnapshot for consistency with fromFirestore signature
      final mockSnapshot = MockDocumentSnapshot({});
      final model = TeamModel.fromFirestore(mockSnapshot, null);

      expect(model.name, isNull);
      expect(model.category, isNull);
      expect(model.image, isNull);
      expect(model.season, isNull);
      expect(model.points, isNull);
      expect(model.win, isNull);
      expect(model.lose, isNull);
      expect(model.draw, isNull);
      expect(model.goals, isNull);
      expect(model.goalsAgainst, isNull);
      expect(model.goalDifference, isNull);
      expect(model.games, isNull);
      expect(model.players, isEmpty); // Expect empty list for null list data
      expect(model.coaches, isEmpty);
      expect(model.delegates, isEmpty);
      expect(model.createdAt, isNull);
    });
  });
}
