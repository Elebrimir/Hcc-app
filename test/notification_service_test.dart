// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeTZDateTime extends Fake implements tz.TZDateTime {}

Event _futureEvent({int hoursFromNow = 2}) => Event(
  id: 'test_event_id',
  title: 'Test Event',
  description: 'Test Description',
  startTime: DateTime.now().add(Duration(hours: hoursFromNow)),
  endTime: DateTime.now().add(Duration(hours: hoursFromNow + 1)),
  confirmedUsers: [],
  location: 'Test Location',
);

Event _pastEvent() => Event(
  id: 'past_event_id',
  title: 'Past Event',
  description: 'Past Description',
  startTime: DateTime.now().subtract(const Duration(hours: 2)),
  endTime: DateTime.now().subtract(const Duration(hours: 1)),
  confirmedUsers: [],
  location: 'Past Location',
);

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(FakeTZDateTime());
    registerFallbackValue(AndroidScheduleMode.exact);
    registerFallbackValue(DateTimeComponents.dateAndTime);
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    NotificationService.pluginForTesting = mockPlugin;
  });

  group('handleNotificationResponse', () {
    test('does nothing when payload is null', () {
      final response = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 1,
        payload: null,
      );
      expect(
        () => NotificationService.handleNotificationResponse(response),
        returnsNormally,
      );
    });

    test('logs message when payload is not null', () {
      final response = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 1,
        payload: 'test_payload',
      );
      expect(
        () => NotificationService.handleNotificationResponse(response),
        returnsNormally,
      );
    });
  });

  group('cancelNotification', () {
    test('calls plugin.cancel with the correct hashed id', () async {
      const String eventId = 'my_event_id';
      final int expectedId = eventId.hashCode;

      when(() => mockPlugin.cancel(id: expectedId)).thenAnswer((_) async {});

      await NotificationService.cancelNotification(eventId);

      verify(() => mockPlugin.cancel(id: expectedId)).called(1);
    });
  });

  group('scheduleEventNotification', () {
    test(
      'returns early without calling zonedSchedule for past events',
      () async {
        final event = _pastEvent();

        await NotificationService.scheduleEventNotification(event);

        verifyNever(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
          ),
        );
      },
    );

    test(
      'calls zonedSchedule with exactAllowWhileIdle for future events',
      () async {
        final event = _futureEvent();

        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {});

        await NotificationService.scheduleEventNotification(event);

        verify(
          () => mockPlugin.zonedSchedule(
            id: event.id.hashCode,
            title: event.title,
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: event.id,
          ),
        ).called(1);
      },
    );

    test(
      'falls back to inexact schedule when exact_alarms_not_permitted',
      () async {
        final event = _futureEvent();
        var callCount = 0;

        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw PlatformException(code: 'exact_alarms_not_permitted');
          }
        });

        await NotificationService.scheduleEventNotification(event);
        verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: any(named: 'payload'),
          ),
        ).called(2);
      },
    );

    test(
      'rethrows PlatformException when code is not exact_alarms_not_permitted',
      () async {
        final event = _futureEvent();

        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            payload: any(named: 'payload'),
          ),
        ).thenThrow(PlatformException(code: 'other_error'));

        expect(
          () => NotificationService.scheduleEventNotification(event),
          throwsA(isA<PlatformException>()),
        );
      },
    );
  });
}
