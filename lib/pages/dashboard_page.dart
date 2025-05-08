// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/pages/profile_page.dart';
import 'package:hcc_app/pages/user_list_page.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/pages/team_page.dart';

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
      const UserListPage(),
      const TeamPage(),
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[500],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Principal'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Usuaris'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Equips'),
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
    final diaSemana = dias[now.weekday - 1];
    final mes = meses[now.month - 1];
    final dia = now.day;
    final any = now.year;

    final article = (mes.startsWith('A') || mes.startsWith('O')) ? "d'" : "de ";

    return "$diaSemana, $dia $article$mes de $any";
  }
}
