// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/event_model.dart'; // Import EventModel
import 'package:mockito/mockito.dart';

class TestDocumentSnapshot {
  final Map<String, dynamic> _data;

  TestDocumentSnapshot(this._data);

  Map<String, dynamic> data() => _data;
}

// MockDocumentSnapshot remains the same as it's generic
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
  group('EventModel tests', () {
    // Update group description
    // Sample UserModels for testing lists
    final eventTraining = Event(
      id: 'event1',
      title: 'Training Session',
      description: 'Thursday evening training',
      startTime: DateTime(2024, 5, 2, 18, 0),
      endTime: DateTime(2024, 5, 2, 20, 0),
      location: 'Cover HCC Field',
      confirmedUsers: ['testCoach', 'testPlayer'],
    );
    test('should create a Event from constructor', () {
      final model = eventTraining;

      expect(model.id, 'event1');
      expect(model.title, 'Training Session');
      expect(model.description, 'Thursday evening training');
      expect(model.startTime, DateTime(2024, 5, 2, 18, 0));
      expect(model.endTime, DateTime(2024, 5, 2, 20, 0));
      expect(model.location, 'Cover HCC Field');
      expect(model.confirmedUsers, ['testCoach', 'testPlayer']);
    });

    test('should create a Event from Firestore snapshot', () {
      final starttime = DateTime(2024, 5, 2, 18, 0);
      final finishtime = starttime.add(Duration(hours: 2));

      final data = {
        'title': 'Saturday Match',
        'description': 'Saturday afternoon match',
        'startTime': Timestamp.fromDate(starttime),
        'endTime': Timestamp.fromDate(finishtime),
        'location': 'Stadium Field',
        'confirmedUsers': ['testCoach', 'testPlayer'],
      };

      final mockSnapshot = MockDocumentSnapshot(data, 'mockEventId123');
      final model = Event.fromFirestore(mockSnapshot);

      expect(model.id, 'mockEventId123');
      expect(model.title, 'Saturday Match');
      expect(model.description, 'Saturday afternoon match');
      expect(model.startTime, starttime);
      expect(model.endTime, finishtime);
      expect(model.location, 'Stadium Field');
      expect(model.confirmedUsers, ['testCoach', 'testPlayer']);
    });

    test('should convert Event to Firestore data', () {
      final model = Event(
        id: 'event2',
        title: 'Team Meeting',
        description: 'Monthly team meeting',
        startTime: DateTime(2024, 5, 5, 19, 0),
        endTime: DateTime(2024, 5, 5, 20, 0),
        location: 'Clubhouse',
        confirmedUsers: ['testCoach'],
      );

      final data = model.toFirestore();

      expect(data['title'], 'Team Meeting');
      expect(data['description'], 'Monthly team meeting');
      expect(
        data['startTime'],
        Timestamp.fromDate(DateTime(2024, 5, 5, 19, 0)),
      );
      expect(data['endTime'], Timestamp.fromDate(DateTime(2024, 5, 5, 20, 0)));
      expect(data['location'], 'Clubhouse');
      expect(data['confirmedUsers'], ['testCoach']);
    });

    // test('should handle null values in fromFirestore', () {
    //   // Use MockDocumentSnapshot for consistency with fromFirestore signature
    //   final mockSnapshot = MockDocumentSnapshot({});
    //   final model = TeamModel.fromFirestore(mockSnapshot, null);

    //   expect(model.name, isNull);
    //   expect(model.category, isNull);
    //   expect(model.image, isNull);
    //   expect(model.season, isNull);
    //   expect(model.points, isNull);
    //   expect(model.win, isNull);
    //   expect(model.lose, isNull);
    //   expect(model.draw, isNull);
    //   expect(model.goals, isNull);
    //   expect(model.goalsAgainst, isNull);
    //   expect(model.goalDifference, isNull);
    //   expect(model.games, isNull);
    //   expect(model.players, isEmpty); // Expect empty list for null list data
    //   expect(model.coaches, isEmpty);
    //   expect(model.delegates, isEmpty);
    //   expect(model.createdAt, isNull);
    // });
  });
}
