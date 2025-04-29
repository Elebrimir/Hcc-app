// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? email;
  final String? name;
  final String? lastname;
  final String? role;
  final String? image;
  final Timestamp? createdAt;

  UserModel({
    this.email,
    this.name,
    this.lastname,
    this.role,
    this.image,
    this.createdAt,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserModel(
      email: data?['email'],
      name: data?['name'],
      lastname: data?['lastname'],
      role: data?['role'],
      image: data?['image'],
      createdAt: data?['created_at'] as Timestamp?,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'],
      name: data['name'],
      lastname: data['lastname'],
      role: data['role'],
      image: data['image'],
      createdAt: data['created_at'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'lastname': lastname,
      'role': role,
      'image': image,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
