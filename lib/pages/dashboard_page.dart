// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/pages/profile_page.dart';
import 'package:hcc_app/utils/responsive_container.dart';
import 'package:hcc_app/widgets/hcc_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/widgets/admin_side_menu.dart';
import 'package:hcc_app/pages/team_page.dart';
import 'package:hcc_app/pages/calendar_page.dart';
import 'package:hcc_app/pages/shop_page.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/widgets/event_form_modal.dart';

import 'package:hcc_app/pages/convocatoria_list_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  final FirebaseFirestore? firestore;

  const DashboardPage({super.key, this.firestore});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      ShopPage(firestore: widget.firestore),
      const CalendarPage(),
      const TeamPage(),
      const ConvocatoriaListPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showEventFormModal(BuildContext context, {Event? event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[800],
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: context.read<UserProvider>(),
          child: EventFormModal(event: event),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.firebaseUser;
    final userModel = userProvider.userModel;
    final userName = userModel?.name;

    return ResponsiveContainer(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: HccAppBar(
          scaffoldKey: _scaffoldKey,
          user: user,
          userName: userName,
          isDashboard: true,
          formattedDate: _getFormattedDate(),
        ),
        drawer: AdminSideMenu(firestore: widget.firestore),
        body: _pages[_selectedIndex],
        floatingActionButton:
            _selectedIndex == 1
                ? FloatingActionButton(
                  onPressed: () {
                    _showEventFormModal(context);
                  },
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
                : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey[900],
          selectedItemColor: Theme.of(context).colorScheme.tertiary,
          unselectedItemColor: Colors.grey[500],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Principal'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tenda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Convocatòries',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Equips'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
        backgroundColor: Colors.grey[800],
      ),
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
