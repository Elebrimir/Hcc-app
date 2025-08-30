// lib/models/event_model.dart
// coverage:ignore-file

import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final List<String> confirmedUsers;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.confirmedUsers,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Event(
      id: snapshot.id,
      title: data['title'],
      description: data['description'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'],
      confirmedUsers: List<String>.from(data['confirmedUsers'] ?? []),
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
    };
  }
}
