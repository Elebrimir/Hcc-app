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
  final List<Atribute> attributes;
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.image,
    required this.attributes,
    required this.createdAt,
  });

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    final attributesData = data?['attributes'] as List<dynamic>?;
    final attributesList =
        attributesData
            ?.map(
              (attr) => (attr is DocumentReference)
                  ? null
                  : Atribute.fromMap(attr as Map<String, dynamic>),
            )
            .whereType<Atribute>()
            .toList() ??
        [];

    return Product(
      id: snapshot.id,
      name: data?['name'] ?? '',
      code: data?['code'] ?? '',
      price: (data?['price'] as num?)?.toDouble() ?? 0.0,
      image: data?['image'] ?? '',
      attributes: attributesList,
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
      attributes:
          (data['attributes'] as List<dynamic>?)
              ?.map((e) => Atribute.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: data['created_at'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'price': price,
      'image': image,
      'attributes': attributes.map((e) => e.toMap()).toList(),
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}

class Atribute {
  final String id;
  final String name;
  final String value;

  Atribute({required this.id, required this.name, required this.value});

  factory Atribute.fromMap(Map<String, dynamic> data) {
    return Atribute(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      value: data['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'value': value};
  }
}
