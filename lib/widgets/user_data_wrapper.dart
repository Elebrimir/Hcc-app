// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/user_model.dart';

class UserDataWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<UserModel>>? userStream;
  final Widget Function(BuildContext context, List<UserModel> users) builder;

  const UserDataWrapper({
    super.key,
    required this.userStream,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<UserModel>>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al carregar els usuaris'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return builder(context, []);
        }
        final List<UserModel> users =
            snapshot.data!.docs
                .map((docSnapshot) => docSnapshot.data())
                .toList();
        return builder(context, users);
      },
    );
  }
}
