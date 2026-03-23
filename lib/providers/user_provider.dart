// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hcc_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isUploadingImage = false;
  bool _isSavingProfile = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isUploadingImage => _isUploadingImage;
  bool get isSavingProfile => _isSavingProfile;

  UserProvider({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance {
    _initializeUser();
  }

  Future<void> initializeUser() async {
    // This method is now mostly redundant but kept for compatibility if needed.
    // The initialization happens in the constructor.
  }

  void _initializeUser() {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (_firebaseUser != null) {
        await _loadUserData(_firebaseUser!);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(User user) async {
    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();

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
    await _auth.signOut();
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
      final Reference storageRef = _storage
          .ref()
          .child('profile_images')
          .child(userId)
          .child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
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
        await _loadUserData(_firebaseUser!);
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
      final DocumentReference userDocRef = _firestore
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
        await _loadUserData(_firebaseUser!);
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
