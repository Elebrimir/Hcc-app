// Copyright (c) 2026 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerModel {
  final String? id;
  final String? name;
  final String? category;
  final String? image;
  final List<String>? parentIds; // List of User UIDs (parents)
  final List<String>? teamIds; // List of team IDs
  final Timestamp? createdAt;

  PlayerModel({
    this.id,
    this.name,
    this.category,
    this.image,
    this.parentIds,
    this.teamIds,
    this.createdAt,
  });

  factory PlayerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PlayerModel(
      id: snapshot.id,
      name: data?['name'],
      category: data?['category'],
      image: data?['image'],
      parentIds:
          data?['parent_ids'] != null
              ? List<String>.from(data?['parent_ids'])
              : null,
      teamIds:
          data?['team_ids'] != null
              ? List<String>.from(data?['team_ids'])
              : null,
      createdAt: data?['created_at'] as Timestamp?,
    );
  }

  factory PlayerModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return PlayerModel(
      id: id,
      name: data['name'],
      category: data['category'],
      image: data['image'],
      parentIds:
          data['parent_ids'] != null
              ? List<String>.from(data['parent_ids'])
              : null,
      teamIds:
          data['team_ids'] != null ? List<String>.from(data['team_ids']) : null,
      createdAt: data['created_at'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'image': image,
      'parent_ids': parentIds,
      'team_ids': teamIds,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
