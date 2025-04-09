import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hcc_app/pages/home_page.dart';

class HccAppBar extends StatefulWidget implements PreferredSizeWidget {
  final User? user;
  final FirebaseAuth? auth;
  final String? userName;
  final String? formattedDate;
  final bool isDashboard;
  final VoidCallback? onSignOut;
  final void Function(BuildContext)?
  onNavigate; // Nueva función para navegación

  const HccAppBar({
    super.key,
    this.user,
    this.auth,
    this.userName,
    this.formattedDate,
    this.isDashboard = false,
    this.onSignOut,
    this.onNavigate, // Nuevo parámetro
  });

  @override
  State<HccAppBar> createState() => _HccAppBarState();
  @override
  Size get preferredSize =>
      Size.fromHeight(isDashboard ? 120.0 : kToolbarHeight);
}

class _HccAppBarState extends State<HccAppBar> {
  User? _user;
  String? _userName;
  String? _formattedDate;
  bool _isDashboard = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _userName = widget.userName;
    _formattedDate = widget.formattedDate;
    _isDashboard = widget.isDashboard;
  }

  Future<void> _onSignOut() async {
    if (context.mounted) {
      if (widget.onNavigate != null) {
        widget.onNavigate!(
          context,
        ); // Usa la función inyectada si está disponible
      } else {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle appBarTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    if (!_isDashboard) {
      return AppBar(
        title:
            _user != null
                ? Text('Bienvenido ${_user?.email}', style: appBarTextStyle)
                : const Text('Hoquei Club Cocentaina', style: appBarTextStyle),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        elevation: 5.0,
        actions: <Widget>[
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: _onSignOut,
            ),
        ],
      );
    } else {
      return AppBar(
        toolbarHeight: 120.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Image.asset('assets/images/logo_club.png', height: 60),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _user != null
                      ? Text(
                        _userName != null
                            ? 'Hola $_userName'.trim()
                            : 'Hola ${_user?.email}',
                        style: appBarTextStyle,
                        textAlign: TextAlign.center,
                      )
                      : const Text(
                        'Hoquei Club Cocentaina',
                        style: appBarTextStyle,
                        textAlign: TextAlign.center,
                      ),
                  if (_formattedDate != null)
                    Text(
                      _formattedDate!,
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
          ],
        ),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        elevation: 25.0,
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _onSignOut,
            ),
        ],
      );
    }
  }
}
