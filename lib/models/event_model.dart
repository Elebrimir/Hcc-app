// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final List<String> confirmedUsers;
  final RecurrenceRule? recurrenceRule;
  final DateTime? recurrenceEndDate;
  final List<DateTime>? excludedDates;
  final String? creatorUid;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.confirmedUsers,
    this.recurrenceRule,
    this.recurrenceEndDate,
    this.excludedDates = const [],
    this.creatorUid,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    RecurrenceRule? recurrenceRule;
    if (data['recurrenceRule'] != null) {
      final ruleData = data['recurrenceRule'] as Map<String, dynamic>;
      recurrenceRule = RecurrenceRule(
        frequency: RecurrenceFrequency.values[ruleData['frequency']],
        interval: ruleData['interval'] ?? 1,
        daysOfWeek: ruleData['daysOfWeek'] != null
            ? List<int>.from(ruleData['daysOfWeek'])
            : null,
        dayOfMonth: ruleData['dayOfMonth'],
        weekOfMonth: ruleData['weekOfMonth'],
      );
    }

    return Event(
      id: snapshot.id,
      title: data['title'],
      description: data['description'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'],
      confirmedUsers: List<String>.from(data['confirmedUsers'] ?? []),
      recurrenceRule: recurrenceRule,
      recurrenceEndDate: data['recurrenceEndDate'] != null
          ? (data['recurrenceEndDate'] as Timestamp).toDate()
          : null,
      excludedDates: data['excludedDates'] != null
          ? (data['excludedDates'] as List)
                .map((date) => (date as Timestamp).toDate())
                .toList()
          : [],
      creatorUid: data['creatorUid'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'confirmedUsers': confirmedUsers,
      'recurrenceRule': recurrenceRule?.toJson(),
      'recurrenceEndDate': recurrenceEndDate != null
          ? Timestamp.fromDate(recurrenceEndDate!)
          : null,
      'excludedDates': excludedDates!
          .map((date) => Timestamp.fromDate(date))
          .toList(),
      'creatorUid': creatorUid,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    List<String>? confirmedUsers,
    RecurrenceRule? recurrenceRule,
    DateTime? recurrenceEndDate,
    List<DateTime>? excludedDates,
    String? creatorUid,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      confirmedUsers: confirmedUsers ?? this.confirmedUsers,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      excludedDates: excludedDates ?? this.excludedDates,
      creatorUid: creatorUid ?? this.creatorUid,
    );
  }
}

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final List<int>? daysOfWeek;
  final int? dayOfMonth;
  final int? weekOfMonth;

  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.weekOfMonth,
  });

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.index,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'weekOfMonth': weekOfMonth,
    };
  }
}

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

extension EventRecurrence on Event {
  List<Event> generateRecurrences({int? maxCount, DateTime? untilDate}) {
    if (recurrenceRule == null) return [this];

    final occurrences = <Event>[];
    var currentStart = startTime;
    var count = 0;

    // Si recurrenceEndDate es null, usamos untilDate como límite (si existe)
    // Si recurrenceEndDate existe, el límite es el menor de los dos (recurrenceEndDate o untilDate)
    final effectiveEndDate = recurrenceEndDate != null
        ? (untilDate != null && untilDate.isBefore(recurrenceEndDate!)
              ? untilDate
              : recurrenceEndDate)
        : untilDate;

    while ((maxCount == null || count < maxCount) &&
        (effectiveEndDate == null ||
            currentStart.isBefore(effectiveEndDate) ||
            currentStart.isAtSameMomentAs(effectiveEndDate))) {
      if (!excludedDates!.any(
        (excluded) => _isSameDay(excluded, currentStart),
      )) {
        occurrences.add(
          Event(
            id: id,
            title: title,
            location: location,
            description: description,
            startTime: currentStart,
            endTime: endTime.add(currentStart.difference(startTime)),
            confirmedUsers: confirmedUsers,
            recurrenceRule: recurrenceRule,
            recurrenceEndDate: recurrenceEndDate,
            excludedDates: excludedDates,
            creatorUid: creatorUid,
          ),
        );
        count++;
      }
      currentStart = _calculateNextDate(currentStart, recurrenceRule!);
    }

    return occurrences;
  }

  DateTime _calculateNextDate(DateTime current, RecurrenceRule rule) {
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        return current.add(Duration(days: rule.interval));
      case RecurrenceFrequency.weekly:
        return current.add(Duration(days: 7 * rule.interval));
      case RecurrenceFrequency.monthly:
        return DateTime(
          current.year,
          current.month + rule.interval,
          current.day,
          current.hour,
          current.minute,
          current.second,
          current.millisecond,
          current.microsecond,
        );
      case RecurrenceFrequency.yearly:
        return DateTime(
          current.year + rule.interval,
          current.month,
          current.day,
          current.hour,
          current.minute,
          current.second,
          current.millisecond,
          current.microsecond,
        );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
