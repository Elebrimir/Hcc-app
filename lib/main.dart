// ignore: unused_import
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HCC App',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hoquei Club Cocentaina',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red[800],
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.all(20.0),
              height: 400,
              child: Image.asset('assets/images/logo_club.png'),
            ),
            const SizedBox(height: 20.0, width: 400),
            ElevatedButton(
              onPressed: () {
                // ignore: avoid_print
                print('Button pressed');
              },
              child: const Text('Notícies'),
            ),
            const SizedBox(height: 40.0),
            const Text(
              'HCC App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[800],
    );
  }
}
