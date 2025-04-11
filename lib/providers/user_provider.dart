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

  Future<void> _initializeUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserData(user);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(User user) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
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
