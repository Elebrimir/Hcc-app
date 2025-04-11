// coverage:ignore-file
// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;

  UserProvider() {
    _initializeUser();
  }

  Future<void> initializeUser({
    User? mockUser,
    FirebaseFirestore? mockFirestore,
  }) async {
    await _initializeUser(mockUser: mockUser, mockFirestore: mockFirestore);
  }

  Future<void> _initializeUser({
    User? mockUser,
    FirebaseFirestore? mockFirestore,
  }) async {
    final authInstance = FirebaseAuth.instance;
    final firestoreInstance = mockFirestore ?? FirebaseFirestore.instance;

    authInstance.authStateChanges().listen((User? user) async {
      _firebaseUser = mockUser ?? user;
      if (_firebaseUser != null) {
        await _loadUserData(_firebaseUser!, firestoreInstance);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(
    User user,
    FirebaseFirestore firestoreInstance,
  ) async {
    try {
      final snapshot =
          await firestoreInstance.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        _userModel = UserModel.fromFirestore(snapshot, null);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }
}
