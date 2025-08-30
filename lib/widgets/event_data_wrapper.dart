// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/event_model.dart';

class EventDataWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>>? eventStream;
  final Widget Function(BuildContext context, List<Event> events) builder;

  const EventDataWrapper({
    super.key,
    required this.eventStream,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (eventStream == null) {
      return builder(context, []);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: eventStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error al carregar els esdeveniments'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return builder(context, []);
        }
        final List<Event> events =
            snapshot.data!.docs.map((doc) => Event.fromFirestore(doc)).toList();

        return builder(context, events);
      },
    );
  }
}
