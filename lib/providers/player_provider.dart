// Copyright (c) 2026 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/player_model.dart';

class PlayerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;

  PlayerProvider({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add a new player
  Future<String> addPlayer(Map<String, dynamic> playerData) async {
    try {
      final docRef = await _firestore.collection('players').add(playerData);
      notifyListeners();
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding player: $e');
      rethrow;
    }
  }

  // Update an existing player
  Future<void> updatePlayer(
    String playerId,
    Map<String, dynamic> playerData,
  ) async {
    try {
      await _firestore.collection('players').doc(playerId).update(playerData);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating player: $e');
      rethrow;
    }
  }

  // Delete a player
  Future<void> deletePlayer(String playerId) async {
    try {
      await _firestore.collection('players').doc(playerId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting player: $e');
      rethrow;
    }
  }

  // Update player's teams
  Future<void> updatePlayerTeams(String playerId, List<String> teamIds) async {
    try {
      await _firestore.collection('players').doc(playerId).update({
        'team_ids': teamIds,
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating player teams: $e');
      rethrow;
    }
  }

  // Get players by parent UID
  Stream<List<PlayerModel>> getPlayersByParent(String parentUid) {
    return _firestore
        .collection('players')
        .where('parent_ids', arrayContains: parentUid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PlayerModel.fromFirestore(doc, null))
                  .toList(),
        );
  }

  // Get players by team ID
  Stream<List<PlayerModel>> getPlayersByTeam(String teamId) {
    return _firestore
        .collection('players')
        .where('team_ids', arrayContains: teamId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PlayerModel.fromFirestore(doc, null))
                  .toList(),
        );
  }
}
