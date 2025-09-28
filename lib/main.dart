// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/services/notification_service.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:hcc_app/auth/auth_wrapper.dart';
import 'package:hcc_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  await NotificationService.requestPermissions();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HCC App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
