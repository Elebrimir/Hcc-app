// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hcc_app/models/user_model.dart'; // Asegúrate que la ruta es correcta
import 'package:hcc_app/providers/user_provider.dart'; // Asegúrate que la ruta es correcta
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  UserProvider? _cachedUserProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _cachedUserProvider = userProvider;
      if (userProvider.userModel != null) {
        _syncControllersWithProvider(userProvider);
      }
      userProvider.addListener(_listenerAndUpdateControllers);
    });
  }

  @override
  void dispose() {
    _cachedUserProvider?.removeListener(_listenerAndUpdateControllers);
    _nameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  void _listenerAndUpdateControllers() {
    if (mounted && _cachedUserProvider != null) {
      _syncControllersWithProvider(_cachedUserProvider!);
    }
  }

  void _syncControllersWithProvider(UserProvider userProvider) {
    if (mounted && userProvider.userModel != null) {
      if (_nameController.text != (userProvider.userModel!.name ?? '')) {
        _nameController.text = userProvider.userModel!.name ?? '';
      }
      if (_lastnameController.text !=
          (userProvider.userModel!.lastname ?? '')) {
        _lastnameController.text = userProvider.userModel!.lastname ?? '';
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.uploadProfileImage(imageFile);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imatge de perfil actualitzada!')),
        );
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al pujar la imatge.')),
        );
      }
    } else {
      debugPrint('No s\'ha seleccionat cap imatge.');
    }
  }

  Future<void> _saveProfileChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final lastname = _lastnameController.text.trim();
    if (name.isEmpty || lastname.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El nom i els cognoms no poden estar buits.'),
          ),
        );
      }
      return;
    }

    final success = await userProvider.saveUserProfileDetails(
      name: name,
      lastname: lastname,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil desat correctament!')),
      );
    } else if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al desar el perfil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userModel = userProvider.userModel;
    final isUploading = userProvider.isUploadingImage;
    final isSaving = userProvider.isSavingProfile;
    final firebaseUser = userProvider.firebaseUser;

    final isLoadingInitialData =
        userModel == null && firebaseUser != null && !isUploading && !isSaving;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoadingInitialData
                ? const Center(child: CircularProgressIndicator())
                : firebaseUser == null
                ? const Center(child: Text('Si us plau, inicia sessió.'))
                : userModel == null
                ? const Center(
                  child: Text('No s\'han pogut carregar les dades.'),
                )
                : _buildProfileForm(
                  context,
                  userProvider,
                  userModel,
                  isUploading,
                  isSaving,
                ),
      ),
    );
  }

  Widget _buildProfileForm(
    BuildContext context,
    UserProvider userProvider,
    UserModel userModel,
    bool isUploading,
    bool isSaving,
  ) {
    final firebaseUser = userProvider.firebaseUser;

    return ListView(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    (userModel.image != null && userModel.image!.isNotEmpty)
                        ? NetworkImage(userModel.image!)
                        : null,
                child:
                    (userModel.image == null || userModel.image!.isEmpty)
                        ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        )
                        : null,
              ),
              if (isUploading)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: Colors.red[900],
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    tooltip: 'Canviar imatge de perfil',
                    onPressed: (isUploading || isSaving) ? null : _pickImage,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        TextFormField(
          initialValue:
              userModel.email ?? firebaseUser?.email ?? 'No disponible',
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: userModel.role ?? 'No disponible',
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Rol',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.verified_user_outlined),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          keyboardType: TextInputType.name,
          enabled: !isUploading && !isSaving,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _lastnameController,
          decoration: const InputDecoration(
            labelText: 'Cognoms',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          keyboardType: TextInputType.name,
          enabled: !isUploading && !isSaving,
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          key: const ValueKey('saveProfileButton'),
          onPressed: (isUploading || isSaving) ? null : _saveProfileChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[900],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child:
              isSaving
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : const Text('Desa canvis'),
        ),
      ],
    );
  }
}
