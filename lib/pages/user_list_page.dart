// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/utils/responsive_container.dart';
import 'package:hcc_app/widgets/user_data_wrapper.dart';
import 'package:hcc_app/widgets/user_display_item.dart';

class UserListPage extends StatelessWidget {
  final FirebaseFirestore? firestore;

  const UserListPage({super.key, this.firestore});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<UserModel>> userStream =
        (firestore ?? FirebaseFirestore.instance)
            .collection('users')
            .withConverter<UserModel>(
              fromFirestore: UserModel.fromFirestore,
              toFirestore: (UserModel user, _) => user.toFirestore(),
            )
            .snapshots();

    return ResponsiveContainer(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Llistat d\'Usuaris',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[900],
          elevation: 0,
        ),
        backgroundColor: Colors.grey[600],

        body: UserDataWrapper(
          builder: (context, users) {
            if (users.isEmpty) {
              return const Center(
                child: Text(
                  'No hi ha usuaris registrats.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return UserDisplayItem(user: user);
              },
            );
          },
          userStream: userStream,
        ),
      ),
    );
  }
}
