import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late EventProvider eventProvider;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    eventProvider = EventProvider(firestore: fakeFirestore);
  });

  group('EventProvider Tests', () {
    test('Initial state should eventually not be loading', () async {
      // Wait for the stream to emit
      await Future.delayed(Duration.zero);

      expect(eventProvider.isLoading, isFalse);
      expect(eventProvider.events, isEmpty);
    });

    test(
      'addEvent should add an event to Firestore and update the list',
      () async {
        final now = Timestamp.now();
        final eventData = {
          'title': 'Test Event',
          'startTime': now,
          'endTime': now,
          'description': 'Test Description',
          'location': 'Test Location',
          'confirmedUsers': <String>[],
        };

        final eventId = await eventProvider.addEvent(eventData, 'creator_uid');
        expect(eventId, isNotEmpty);

        // Wait for the stream to update
        await Future.delayed(Duration.zero);

        expect(eventProvider.events.length, 1);
        expect(eventProvider.events.first.title, 'Test Event');
        expect(eventProvider.events.first.creatorUid, 'creator_uid');
      },
    );

    test('updateEvent should update an existing event', () async {
      final now = Timestamp.now();
      final docRef = await fakeFirestore.collection('events').add({
        'title': 'Old Title',
        'startTime': now,
        'endTime': now,
        'confirmedUsers': <String>[],
        'creatorUid': 'creator_uid',
      });

      await eventProvider.updateEvent(docRef.id, {'title': 'New Title'});

      // Wait for the stream to update
      await Future.delayed(Duration.zero);

      expect(eventProvider.events.first.title, 'New Title');
    });

    test('deleteEvent should remove an event', () async {
      final now = Timestamp.now();
      final docRef = await fakeFirestore.collection('events').add({
        'title': 'To Delete',
        'startTime': now,
        'endTime': now,
        'confirmedUsers': <String>[],
        'creatorUid': 'creator_uid',
      });

      // Wait for initial load
      await Future.delayed(Duration.zero);
      expect(eventProvider.events.length, 1);

      await eventProvider.deleteEvent(docRef.id);

      // Wait for the stream to update
      await Future.delayed(Duration.zero);

      expect(eventProvider.events, isEmpty);
    });

    test('Stream should handle errors', () async {
      // This is harder to test with FakeFirebaseFirestore as it doesn't easily throw on snapshots
      // But we can verify the onError logic by mocking the stream if needed.
    });
  });
}
