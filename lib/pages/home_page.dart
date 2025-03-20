import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'registration_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _user != null
                ? Text(
                  'Bienvenido ${_user!.email}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : const Text(
                  'Hoquei Club Cocentaina',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
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
              if (FirebaseAuth.instance.currentUser ==
                  null) // Si no hay usuario autenticado
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
              if (FirebaseAuth.instance.currentUser ==
                  null) // Si no hay usuario autenticado
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
              if (FirebaseAuth.instance.currentUser !=
                  null) // Si hay usuario autenticado
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Cerrar Sesión'),
                ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
