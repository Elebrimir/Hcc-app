// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String code;
  final double price;
  final String image;
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.image,
    required this.createdAt,
  });

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Product(
      id: snapshot.id,
      name: data?['name'] ?? '',
      code: data?['code'] ?? '',
      price: (data?['price'] as num?)?.toDouble() ?? 0.0,
      image: data?['image'] ?? '',
      createdAt: data?['created_at'] as Timestamp? ?? Timestamp.now(),
    );
  }

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
      createdAt: data['created_at'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'price': price,
      'image': image,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
