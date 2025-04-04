import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hcc_app/pages/profile_page.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  User? _user;
  UserModel? _userModel;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      _loadUserData();
    }

    _pages = [
      const Center(
        child: Text(
          "Inici",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      const Center(
        child: Text(
          "Calendari",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      const ProfilePage(),
    ];

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      if (_user != null) {
        _loadUserData();
      } else {
        setState(() {
          _userModel = null;
        });
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user?.uid)
              .get();
      if (snapshot.exists) {
        setState(() {
          _userModel = UserModel.fromFirestore(snapshot, null);
        });
      }
    } catch (e) {
      log('Error loading user data: $e', name: 'DashboardPage');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
      appBar: HccAppBar(
        user: _user,
        userName: _userModel?.name,
        isDashboard: true,
        formattedDate: fechaFormateada,
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
