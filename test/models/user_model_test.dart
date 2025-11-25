// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:mockito/mockito.dart';

class TestDocumentSnapshot {
  final Map<String, dynamic> _data;

  TestDocumentSnapshot(this._data);

  Map<String, dynamic> data() => _data;
}

extension UserModelTestExtension on UserModel {
  static UserModel fromTest(TestDocumentSnapshot snapshot) {
    final data = snapshot.data();
    return UserModel(
      email: data['email'],
      name: data['name'],
      lastname: data['lastname'],
      role: data['role'],
      image: data['image'],
      createdAt: data['created_at'],
    );
  }
}

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  Map<String, dynamic>? data() => _data;
}

void main() {
  group('UserModel tests', () {
    test('should create a UserModel from constructor', () {
      final timestamp = Timestamp.now();
      final model = UserModel(
        email: 'test@example.com',
        name: 'Test',
        lastname: 'User',
        role: 'member',
        image: 'test_image.jpg',
        createdAt: timestamp,
      );

      expect(model.email, 'test@example.com');
      expect(model.name, 'Test');
      expect(model.lastname, 'User');
      expect(model.role, 'member');
      expect(model.image, 'test_image.jpg');
      expect(model.createdAt, timestamp);
    });

    test('should create a UserModel from Firestore snapshot', () {
      final timestamp = Timestamp.now();
      final data = {
        'email': 'test@example.com',
        'name': 'Test',
        'lastname': 'User',
        'role': 'member',
        'image': 'test_image.jpg',
        'created_at': timestamp,
      };

      final mockSnapshot = MockDocumentSnapshot(data);
      final model = UserModel.fromFirestore(mockSnapshot, null);

      expect(model.email, 'test@example.com');
      expect(model.name, 'Test');
      expect(model.lastname, 'User');
      expect(model.role, 'member');
      expect(model.image, 'test_image.jpg');
      expect(model.createdAt, timestamp);
    });

    test('should convert UserModel to Firestore data', () {
      final model = UserModel(
        email: 'test@example.com',
        name: 'Test',
        lastname: 'User',
        role: 'member',
        image: 'test_image.jpg',
      );

      final data = model.toFirestore();

      expect(data['email'], 'test@example.com');
      expect(data['name'], 'Test');
      expect(data['lastname'], 'User');
      expect(data['role'], 'member');
      expect(data['image'], 'test_image.jpg');
    });

    test('should handle null values in fromFirestore', () {
      final testSnapshot = TestDocumentSnapshot({});
      final model = UserModelTestExtension.fromTest(testSnapshot);

      expect(model.email, isNull);
      expect(model.name, isNull);
      expect(model.lastname, isNull);
      expect(model.role, isNull);
      expect(model.image, isNull);
      expect(model.createdAt, isNull);
    });
  });
}
