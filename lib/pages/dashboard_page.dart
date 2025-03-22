import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  User? _user;

  static const List<Widget> _pages = [
    Center(
      child: Text("Inici", style: TextStyle(color: Colors.white, fontSize: 24)),
    ),
    Center(
      child: Text(
        "Calendari",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    Center(
      child: Text(
        "Perfil",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final meses = [
      'Gener',
      'Febrer',
      'Març',
      'Abril',
      'Maig',
      'Juny',
      'Juliol',
      'Agost',
      'Septembre',
      'Octubre',
      'Novembre',
      'Desembre',
    ];
    final dias = [
      'Dillluns',
      'Dimarts',
      'Dimecres',
      'Dijous',
      'Divendres',
      'Dissabte',
      'Diumenge',
    ];

    String fechaFormateada;

    if (meses[now.month - 1] == 'Abril' ||
        meses[now.month - 1] == 'Agost' ||
        meses[now.month - 1] == 'Octubre') {
      fechaFormateada =
          '${dias[now.weekday - 1]}, ${now.day} d\'${meses[now.month - 1]} de ${now.year}';
    } else {
      fechaFormateada =
          '${dias[now.weekday - 1]}, ${now.day} de ${meses[now.month - 1]} de ${now.year}';
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Image.asset('assets/images/logo_club.png', height: 60),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _user != null
                      ? Text(
                        'Dashboard - ${_user?.email}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                      : const Text(
                        'Hoquei Club Cocentaina',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  Text(
                    fechaFormateada,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Image.asset('assets/images/logo_club.png', height: 60),
            ),
          ],
        ),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        elevation: 25.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Cerrar sesión
              await FirebaseAuth.instance.signOut();
              // Redirigir al login
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inici'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendari',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      backgroundColor: Colors.grey[800],
    );
  }
}
