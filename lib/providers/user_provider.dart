// coverage:ignore-file
// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hcc_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isUploadingImage = false;
  bool _isSavingProfile = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isUploadingImage => _isUploadingImage;
  bool get isSavingProfile => _isSavingProfile;

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
      } else {
        _userModel = null;
        debugPrint('Documento de usuario no encontrado para UID: ${user.uid}');
      }
    } catch (e) {
      _userModel = null;
      debugPrint('Error al cargar datos de usuario: $e');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _firebaseUser = null;
    _userModel = null;
    _isUploadingImage = false;
    _isSavingProfile = false;
    notifyListeners();
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    if (_firebaseUser == null) {
      debugPrint('Error: Usuario no autenticado para subir imagen.');
      return false;
    }

    _isUploadingImage = true;
    notifyListeners();

    bool success = false;
    try {
      final String userId = _firebaseUser!.uid;
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(userId)
          .child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      await userDocRef.update({'image': downloadUrl});

      if (_userModel != null) {
        _userModel = UserModel(
          email: _userModel!.email,
          name: _userModel!.name,
          lastname: _userModel!.lastname,
          role: _userModel!.role,
          createdAt: _userModel!.createdAt,
          image: downloadUrl,
        );
      } else {
        await _loadUserData(_firebaseUser!, FirebaseFirestore.instance);
      }

      success = true;
      debugPrint('Imagen de perfil subida y Firestore actualizado.');
    } on FirebaseException catch (e) {
      debugPrint('Error Firebase al subir imagen: ${e.message}');
      success = false;
    } catch (e) {
      debugPrint('Error inesperado al subir imagen: $e');
      success = false;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> saveUserProfileDetails({
    required String name,
    required String lastname,
  }) async {
    if (_firebaseUser == null) {
      debugPrint('Error: Usuario no autenticado para guardar perfil.');
      return false;
    }

    _isSavingProfile = true;
    notifyListeners();

    bool success = false;
    try {
      final String userId = _firebaseUser!.uid;
      final DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      final Map<String, dynamic> dataToUpdate = {
        'name': name,
        'lastname': lastname,
      };

      await userDocRef.update(dataToUpdate);

      if (_userModel != null) {
        _userModel = UserModel(
          email: _userModel!.email,
          role: _userModel!.role,
          image: _userModel!.image,
          createdAt: _userModel!.createdAt,
          name: name,
          lastname: lastname,
        );
      } else {
        await _loadUserData(_firebaseUser!, FirebaseFirestore.instance);
      }

      success = true;
      debugPrint(
        'Detalles del perfil guardados en Firestore y provider actualizado.',
      );
    } on FirebaseException catch (e) {
      debugPrint('Error Firebase al guardar perfil: ${e.message}');
      success = false;
    } catch (e) {
      debugPrint('Error inesperado al guardar perfil: $e');
      success = false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
    return success;
  }
}
