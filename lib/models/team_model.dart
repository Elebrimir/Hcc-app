// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/user_model.dart';

class TeamModel {
  final String? name;
  final String? category;
  final String? image;
  final int? season;
  final int? points;
  final int? win;
  final int? lose;
  final int? draw;
  final int? goals;
  final int? goalsAgainst;
  final int? goalDifference;
  final int? games;
  final List<UserModel>? players;
  final List<UserModel>? coaches;
  final List<UserModel>? delegates;
  final Timestamp? createdAt;

  TeamModel({
    this.name,
    this.category,
    this.image,
    this.season,
    this.points,
    this.win,
    this.lose,
    this.draw,
    this.goals,
    this.goalsAgainst,
    this.goalDifference,
    this.games,
    this.players,
    this.coaches,
    this.delegates,
    this.createdAt,
  });

  factory TeamModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    final playersData = data?['players'] as List<dynamic>?;
    final coachesData = data?['coaches'] as List<dynamic>?;
    final delegatesData = data?['delegates'] as List<dynamic>?;

    final playersList =
        playersData
            ?.map((player) => UserModel.fromMap(player as Map<String, dynamic>))
            .toList() ??
        [];
    final coachesList =
        coachesData
            ?.map((coach) => UserModel.fromMap(coach as Map<String, dynamic>))
            .toList() ??
        [];
    final delegatesList =
        delegatesData
            ?.map(
              (delegate) => UserModel.fromMap(delegate as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return TeamModel(
      name: data?['name'],
      category: data?['category'],
      image: data?['image'],
      season: data?['season'],
      points: data?['points'],
      win: data?['win'],
      lose: data?['lose'],
      draw: data?['draw'],
      goals: data?['goals'],
      goalsAgainst: data?['goals_against'],
      goalDifference: data?['goal_difference'],
      games: data?['games'],
      players: playersList,
      coaches: coachesList,
      delegates: delegatesList,
      createdAt: data?['created_at'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'image': image,
      'season': season,
      'points': points,
      'win': win,
      'lose': lose,
      'draw': draw,
      'goals': goals,
      'goals_against': goalsAgainst,
      'goal_difference': goalDifference,
      'games': games,
      'players': players?.map((e) => e.toFirestore()).toList(),
      'coaches': coaches?.map((e) => e.toFirestore()).toList(),
      'delegates': delegates?.map((e) => e.toFirestore()).toList(),
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
