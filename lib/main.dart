import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            title: 'HCC App',
            theme: ThemeData(primarySwatch: Colors.red),
            home: const HomePage(),
          );
        } else {
          return MaterialApp(
            title: 'HCC App',
            theme: ThemeData(primarySwatch: Colors.red),
            home: HomePage(),
          );
        }
      },
    );
  }
}
