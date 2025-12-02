// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/user_provider.dart';

class HccAppBar extends StatefulWidget implements PreferredSizeWidget {
  final User? user;
  final FirebaseAuth? auth;
  final String? userName;
  final String? formattedDate;
  final bool isDashboard;
  final VoidCallback? onSignOut;
  final void Function(BuildContext)? onNavigate;

  const HccAppBar({
    super.key,
    this.user,
    this.auth,
    this.userName,
    this.formattedDate,
    this.isDashboard = false,
    this.onSignOut,
    this.onNavigate,
  });

  @override
  State<HccAppBar> createState() => _HccAppBarState();
  @override
  Size get preferredSize =>
      Size.fromHeight(isDashboard ? 120.0 : kToolbarHeight);
}

class _HccAppBarState extends State<HccAppBar> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    final firebaseUser = userProvider.firebaseUser;

    const TextStyle appBarTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    if (!widget.isDashboard) {
      return AppBar(
        title:
            firebaseUser != null
                ? Text(
                  'Bienvenido ${userModel?.name ?? firebaseUser.email}',
                  style: appBarTextStyle,
                )
                : const Text('Hoquei Club Cocentaina', style: appBarTextStyle),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          if (firebaseUser != null)
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () => userProvider.signOut(),
            ),
        ],
      );
    } else {
      return AppBar(
        toolbarHeight: 120.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Image.asset('assets/images/logo_club.png', height: 60),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  firebaseUser != null
                      ? Text(
                        userModel?.name != null
                            ? 'Hola ${userModel?.name}'.trim()
                            : 'Hola ${firebaseUser.email}',
                        style: appBarTextStyle,
                        textAlign: TextAlign.center,
                      )
                      : const Text(
                        'Hoquei Club Cocentaina',
                        style: appBarTextStyle,
                        textAlign: TextAlign.center,
                      ),
                  if (widget.formattedDate != null)
                    Text(
                      widget.formattedDate!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        elevation: 25.0,
        actions: [
          if (firebaseUser != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => userProvider.signOut(),
            ),
        ],
      );
    }
  }
}
