// Copyright (c) 2026 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/team_model.dart';

class TeamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;

  TeamProvider({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add a new team
  Future<String> addTeam(Map<String, dynamic> teamData) async {
    try {
      final docRef = await _firestore.collection('teams').add(teamData);
      notifyListeners();
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding team: $e');
      rethrow;
    }
  }

  // Update an existing team
  Future<void> updateTeam(String teamId, Map<String, dynamic> teamData) async {
    try {
      await _firestore.collection('teams').doc(teamId).update(teamData);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating team: $e');
      rethrow;
    }
  }

  // Get all teams
  Stream<List<TeamModel>> getTeams() {
    return _firestore
        .collection('teams')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => TeamModel.fromFirestore(doc, null))
                  .toList(),
        );
  }

  // Delete a team
  Future<void> deleteTeam(String teamId) async {
    try {
      await _firestore.collection('teams').doc(teamId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting team: $e');
      rethrow;
    }
  }
}
