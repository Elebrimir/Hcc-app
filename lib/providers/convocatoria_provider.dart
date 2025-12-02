import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:hcc_app/models/event_model.dart';

class ConvocatoriaProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  ConvocatoriaProvider({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  List<ConvocatoriaModel> _convocatorias = [];
  List<ConvocatoriaModel> get convocatorias => _convocatorias;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> createConvocatoria({
    required String teamId,
    required String teamName,
    required Event event,
    required List<ConvokedUser> players,
    required List<ConvokedUser> delegates,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Create Event
      final eventRef = _firestore.collection('events').doc();
      final eventWithId = event.copyWith(id: eventRef.id);
      await eventRef.set(eventWithId.toFirestore());

      // 2. Create Convocatoria linked to Event
      final convocatoriaRef = _firestore.collection('convocatorias').doc();
      final convocatoria = ConvocatoriaModel(
        id: convocatoriaRef.id,
        teamId: teamId,
        teamName: teamName,
        eventId: eventRef.id,
        players: players,
        delegates: delegates,
        createdAt: Timestamp.now(),
      );

      await convocatoriaRef.set(convocatoria.toFirestore());

      _convocatorias.add(convocatoria);
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating convocatoria: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchConvocatorias() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('convocatorias')
              .orderBy('createdAt', descending: true)
              .get();

      _convocatorias =
          snapshot.docs
              .map((doc) => ConvocatoriaModel.fromFirestore(doc))
              .toList();
    } catch (e) {
      debugPrint('Error fetching convocatorias: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateConvocationStatus(
    String convocatoriaId,
    String userId,
    ConvocationStatus newStatus,
  ) async {
    try {
      final docRef = _firestore.collection('convocatorias').doc(convocatoriaId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;

      final convocatoria = ConvocatoriaModel.fromFirestore(snapshot);

      // Check players
      final playerIndex = convocatoria.players.indexWhere(
        (p) => p.userId == userId,
      );
      if (playerIndex != -1) {
        final updatedPlayers = List<ConvokedUser>.from(convocatoria.players);
        updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
          status: newStatus,
        );
        await docRef.update({
          'players': updatedPlayers.map((e) => e.toMap()).toList(),
        });
      }

      // Check delegates
      final delegateIndex = convocatoria.delegates.indexWhere(
        (d) => d.userId == userId,
      );
      if (delegateIndex != -1) {
        final updatedDelegates = List<ConvokedUser>.from(
          convocatoria.delegates,
        );
        updatedDelegates[delegateIndex] = updatedDelegates[delegateIndex]
            .copyWith(status: newStatus);
        await docRef.update({
          'delegates': updatedDelegates.map((e) => e.toMap()).toList(),
        });
      }

      // Refresh local list
      await fetchConvocatorias();
    } catch (e) {
      debugPrint('Error updating status: $e');
      rethrow;
    }
  }
}
