// ignore_for_file: subtype_of_sealed_class, prefer_const_constructors
// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/event_model.dart';

Map<DateTime, List<Event>> _groupEvents(List<Event> events) {
  Map<DateTime, List<Event>> data = {};
  for (var event in events) {
    final date = DateTime.utc(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
    );
    if (data[date] == null) data[date] = [];
    data[date]!.add(event);
  }
  return data;
}

void main() {
  group('_groupEvents Logic Test', () {
    test('Debe agrupar correctamente los eventos por día', () {
      final events = [
        Event(
          id: '1',
          title: 'Event 1',
          startTime: DateTime.utc(2025, 9, 15, 10, 0),
          endTime: DateTime.utc(2025, 9, 15, 11, 0),
          confirmedUsers: [],
        ),
        Event(
          id: '2',
          title: 'Event 2',
          startTime: DateTime.utc(2025, 9, 15, 12, 0),
          endTime: DateTime.utc(2025, 9, 15, 13, 0),
          confirmedUsers: [],
        ),
        Event(
          id: '3',
          title: 'Event 3',
          startTime: DateTime.utc(2025, 9, 20, 18, 0),
          endTime: DateTime.utc(2025, 9, 20, 19, 0),
          confirmedUsers: [],
        ),
      ];

      final grouped = _groupEvents(events);
      expect(grouped.length, 2);

      final day15 = DateTime.utc(2025, 9, 15);
      expect(grouped[day15], isNotNull);
      expect(grouped[day15]!.length, 2);
      expect(
        grouped[day15]!.map((e) => e.title),
        containsAll(['Event 1', 'Event 2']),
      );

      final day20 = DateTime.utc(2025, 9, 20);
      expect(grouped[day20], isNotNull);
      expect(grouped[day20]!.length, 1);
      expect(grouped[day20]![0].title, 'Event 3');
    });
  });
}
