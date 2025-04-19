// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/pages/profile_page.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/user_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.firebaseUser;
    final userModel = userProvider.userModel;
    final userName = userModel?.name;

    return Scaffold(
      appBar: HccAppBar(
        user: user,
        userName: userName,
        isDashboard: true,
        formattedDate: _getFormattedDate(),
      ),
      // body: IndexedStack(index: _selectedIndex, children: _pages),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Principal'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      backgroundColor: Colors.grey[800],
    );
  }

  String _getFormattedDate() {
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

    if (meses[now.month - 1] == 'Abril' ||
        meses[now.month - 1] == 'Agost' ||
        meses[now.month - 1] == 'Octubre') {
      return '${dias[now.weekday - 1]}, ${now.day} d\'${meses[now.month - 1]} de ${now.year}';
    } else {
      return '${dias[now.weekday - 1]}, ${now.day} de ${meses[now.month - 1]} de ${now.year}';
    }
  }
}
