// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  const ProfilePage({super.key, this.auth, this.firestore});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? FirebaseAuth.instance;
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No hi ha ninún usuari autenticat.';
      });
      return;
    }

    const String usersCollection = 'users';

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection(usersCollection)
              .doc(currentUser.uid)
              .get();

      if (snapshot.exists) {
        setState(() {
          _userModel = UserModel.fromFirestore(snapshot, null);
          _nameController.text = _userModel?.name ?? '';
          _lastnameController.text = _userModel?.lastname ?? '';
        });
      } else {
        setState(() {
          _errorMessage = 'Perfil d\'usuari no trobat.';
          _nameController.text = currentUser.displayName ?? '';
          _lastnameController.text = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al carregar el perfil d\'usuari: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserProfile() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hi ha ninún usuari autenticat.')),
      );
      return;
    }

    setState(() {});

    const String usersCollection = 'users';

    Map<String, dynamic> dataToUpdate = {
      'name': _nameController.text.trim(),
      'lastname': _lastnameController.text.trim(),
    };

    try {
      await _firestore
          .collection(usersCollection)
          .doc(currentUser.uid)
          .update(dataToUpdate);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualitzat correctament.')),
      );
      _loadUserProfile(); // Reload the user profile to reflect changes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualitzar el perfil: $e')),
      );
    } finally {
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker no implementat.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : _userModel == null && !_isLoading
                ? const Center(
                  child: Text('No es pot carregar el perfil d\'usuari.'),
                )
                : ListView(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            child:
                                _userModel?.image == null ||
                                        _userModel!.image!.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          Material(
                            color: Colors.red[900],
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              tooltip:
                                  'Molt aviat podràs canviar '
                                  'la teva imatge de perfil',
                              onPressed: _pickImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      initialValue: _userModel?.email ?? 'No disponible',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      initialValue: _userModel?.role ?? 'No disponible',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.rule),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: const InputDecoration(
                        labelText: 'Cognoms',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Desa canvis'),
                    ),
                  ],
                ),
      ),
    );
  }
}
