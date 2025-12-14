// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hcc_app/pages/user_list_page.dart';

class AdminSideMenu extends StatelessWidget {
  final FirebaseFirestore? firestore;

  const AdminSideMenu({super.key, this.firestore});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.red[900]),
            child: Row(
              children: [
                Image.asset('assets/images/logo_club.png', height: 60),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Menú d\'Administració',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Usuaris', style: TextStyle(color: Colors.white)),
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop(); // Close the drawer
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => UserListPage(firestore: firestore),
                ),
              );
            },
          ),
          // Add more admin items here
        ],
      ),
    );
  }
}
