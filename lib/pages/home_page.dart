// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/utils/responsive_container.dart';
import 'package:hcc_app/widgets/login_widget.dart';
import 'package:hcc_app/widgets/registration_widget.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final user = Provider.of<UserProvider>(context).firebaseUser;
  late final userName = user?.displayName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Scaffold(
        appBar: HccAppBar(
          user: user,
          userName: userName,
          formattedDate: DateTime.now().toString(),
          isDashboard: false,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsets.all(20.0),
                  height: 400,
                  child: Image.asset('assets/images/logo_club.png'),
                ),
                const SizedBox(height: 20.0),
                if (user == null)
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return RegistrationPage(homePageContext: context);
                        },
                      );
                    },
                    child: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Icon(Icons.app_registration),
                          Text('Registro'),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20.0),
                if (user == null)
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return LoginPage(homePageContext: context);
                        },
                      );
                    },
                    child: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Icon(Icons.login),
                          Text('Acceso'),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20.0),
                if (user != null)
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).signOut();
                    },
                    child: const Text('Cerrar Sesión'),
                  ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
