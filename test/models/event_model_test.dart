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
    test('should copy Event with updated values', () {
      final model = eventTraining;
      final updatedModel = model.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
        startTime: DateTime(2024, 5, 3, 10, 0),
        endTime: DateTime(2024, 5, 3, 12, 0),
        location: 'Updated Location',
        confirmedUsers: ['user1'],
        creatorUid: 'creator123',
      );

      expect(updatedModel.id, model.id);
      expect(updatedModel.title, 'Updated Title');
      expect(updatedModel.description, 'Updated Description');
      expect(updatedModel.startTime, DateTime(2024, 5, 3, 10, 0));
      expect(updatedModel.endTime, DateTime(2024, 5, 3, 12, 0));
      expect(updatedModel.location, 'Updated Location');
      expect(updatedModel.confirmedUsers, ['user1']);
      expect(updatedModel.creatorUid, 'creator123');
    });

    test('should handle complex fields in fromFirestore', () {
      final starttime = DateTime(2024, 5, 2, 18, 0);
      final finishtime = starttime.add(Duration(hours: 2));
      final recurrenceEnd = DateTime(2024, 12, 31);
      final excludedDate = DateTime(2024, 6, 1);

      final data = {
        'title': 'Recurring Event',
        'description': 'Weekly meeting',
        'startTime': Timestamp.fromDate(starttime),
        'endTime': Timestamp.fromDate(finishtime),
        'location': 'Office',
        'confirmedUsers': ['user1'],
        'creatorUid': 'creator123',
        'recurrenceRule': {
          'frequency': RecurrenceFrequency.weekly.index,
          'interval': 1,
          'daysOfWeek': [1, 3],
        },
        'recurrenceEndDate': Timestamp.fromDate(recurrenceEnd),
        'excludedDates': [Timestamp.fromDate(excludedDate)],
      };

      final mockSnapshot = MockDocumentSnapshot(data, 'event_complex');
      final model = Event.fromFirestore(mockSnapshot);

      expect(model.recurrenceRule, isNotNull);
      expect(model.recurrenceRule!.frequency, RecurrenceFrequency.weekly);
      expect(model.recurrenceRule!.interval, 1);
      expect(model.recurrenceRule!.daysOfWeek, [1, 3]);
      expect(model.recurrenceEndDate, recurrenceEnd);
      expect(model.excludedDates, [excludedDate]);
      expect(model.creatorUid, 'creator123');
    });

    test('should handle complex fields in toFirestore', () {
      final starttime = DateTime(2024, 5, 2, 18, 0);
      final finishtime = starttime.add(Duration(hours: 2));
      final recurrenceEnd = DateTime(2024, 12, 31);
      final excludedDate = DateTime(2024, 6, 1);

      final model = Event(
        id: 'event_complex',
        title: 'Recurring Event',
        startTime: starttime,
        endTime: finishtime,
        confirmedUsers: [],
        creatorUid: 'creator123',
        recurrenceRule: RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          daysOfWeek: [1, 3],
        ),
        recurrenceEndDate: recurrenceEnd,
        excludedDates: [excludedDate],
      );

      final data = model.toFirestore();

      expect(data['creatorUid'], 'creator123');
      expect(data['recurrenceRule'], isNotNull);
      expect(
        data['recurrenceRule']['frequency'],
        RecurrenceFrequency.weekly.index,
      );
      expect(data['recurrenceEndDate'], Timestamp.fromDate(recurrenceEnd));
      expect(data['excludedDates'], [Timestamp.fromDate(excludedDate)]);
    });
  });

  group('EventRecurrence tests', () {
    final baseEvent = Event(
      id: 'recur_1',
      title: 'Daily Standup',
      startTime: DateTime(2024, 1, 1, 9, 0), // Monday
      endTime: DateTime(2024, 1, 1, 9, 15),
      confirmedUsers: [],
    );

    test('should generate daily recurrences', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.daily),
      );

      final occurrences = event.generateRecurrences(maxCount: 5);

      expect(occurrences.length, 5);
      expect(occurrences[0].startTime, DateTime(2024, 1, 1, 9, 0));
      expect(occurrences[1].startTime, DateTime(2024, 1, 2, 9, 0));
      expect(occurrences[4].startTime, DateTime(2024, 1, 5, 9, 0));
    });

    test('should generate weekly recurrences', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.weekly),
      );

      final occurrences = event.generateRecurrences(maxCount: 3);

      expect(occurrences.length, 3);
      expect(occurrences[0].startTime, DateTime(2024, 1, 1, 9, 0)); // Mon
      expect(occurrences[1].startTime, DateTime(2024, 1, 8, 9, 0)); // Next Mon
      expect(occurrences[2].startTime, DateTime(2024, 1, 15, 9, 0));
    });

    test('should generate monthly recurrences', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.monthly),
      );

      final occurrences = event.generateRecurrences(maxCount: 3);

      expect(occurrences.length, 3);
      expect(occurrences[0].startTime, DateTime(2024, 1, 1, 9, 0));
      expect(occurrences[1].startTime, DateTime(2024, 2, 1, 9, 0));
      expect(occurrences[2].startTime, DateTime(2024, 3, 1, 9, 0));
    });

    test('should generate yearly recurrences', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.yearly),
      );

      final occurrences = event.generateRecurrences(maxCount: 3);

      expect(occurrences.length, 3);
      expect(occurrences[0].startTime, DateTime(2024, 1, 1, 9, 0));
      expect(occurrences[1].startTime, DateTime(2025, 1, 1, 9, 0));
      expect(occurrences[2].startTime, DateTime(2026, 1, 1, 9, 0));
    });

    test('should respect recurrenceEndDate', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceEndDate: DateTime(2024, 1, 3, 23, 59),
      );

      final occurrences = event.generateRecurrences(maxCount: 10);

      expect(occurrences.length, 3); // 1st, 2nd, 3rd
      expect(occurrences.last.startTime.day, 3);
    });

    test('should respect untilDate', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.daily),
      );

      final occurrences = event.generateRecurrences(
        untilDate: DateTime(2024, 1, 3, 23, 59),
      );

      expect(occurrences.length, 3); // 1st, 2nd, 3rd
      expect(occurrences.last.startTime.day, 3);
    });

    test('should use earlier of recurrenceEndDate and untilDate', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceEndDate: DateTime(2024, 1, 5, 23, 59),
      );

      // untilDate is earlier
      final occurrences1 = event.generateRecurrences(
        untilDate: DateTime(2024, 1, 3, 23, 59),
      );
      expect(occurrences1.length, 3);

      // recurrenceEndDate is earlier
      final occurrences2 = event.generateRecurrences(
        untilDate: DateTime(2024, 1, 10, 23, 59),
      );
      expect(occurrences2.length, 5);
    });

    test('should skip excluded dates', () {
      final event = baseEvent.copyWith(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.daily),
        excludedDates: [DateTime(2024, 1, 2, 0, 0)], // Exclude 2nd Jan
      );

      final occurrences = event.generateRecurrences(maxCount: 3);

      expect(occurrences.length, 3);
      expect(occurrences[0].startTime.day, 1);
      expect(occurrences[1].startTime.day, 3); // Skipped 2
      expect(occurrences[2].startTime.day, 4);
    });
  });
}
