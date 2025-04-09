import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hcc_app/pages/dashboard_page.dart';
import 'package:hcc_app/pages/login_page.dart';
import 'package:hcc_app/pages/registration_page.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
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

      if (_user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HccAppBar(
        user: _user,
        userName: _user != null ? _user!.email : 'Invitado',
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
