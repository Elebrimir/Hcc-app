// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late StreamSubscription _eventsSubscription;

  List<Event> _events = [];
  bool _isLoading = true;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  EventProvider() {
    _fetchEvents();
  }

  void _fetchEvents() {
    _eventsSubscription = _db
        .collection('events')
        .snapshots()
        .listen(
          (snapshot) {
            _events =
                snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            debugPrint("Error al escuchar los eventos: $error");
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  Future<String> addEvent(
    Map<String, dynamic> eventData,
    String creatorUid,
  ) async {
    try {
      final eventMap = {
        'title': eventData['title'],
        'creatorUid': creatorUid,
        'description': eventData['description'] ?? '',
        'location': eventData['location'] ?? '',
        'startTime': Timestamp.fromDate(eventData['startTime']),
        'endTime': Timestamp.fromDate(
          eventData['startTime'].add(const Duration(hours: 1)),
        ),
        'confirmedUsers': [],
      };
      final docRef = await _db.collection('events').add(eventMap);
      return docRef.id;
    } catch (e) {
      debugPrint("Error en afegir l'esdeveniment: $e");
      return '';
    }
  }

  Future<void> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final eventMap = {
        'title': eventData['title'],
        'startTime': Timestamp.fromDate(eventData['startTime']),
        'endTime': Timestamp.fromDate(eventData['endTime']),
        'description': eventData['description'],
      };
      await _db.collection('events').doc(eventId).update(eventMap);
    } catch (e) {
      print("Error en actualitzar l'esdeveniment: $e");
    }
  }
}
