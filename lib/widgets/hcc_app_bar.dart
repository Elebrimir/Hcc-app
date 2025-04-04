import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hcc_app/pages/home_page.dart';

class HccAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final String? userName;
  final bool isDashboard;
  final VoidCallback? onSignOut;
  final String? formattedDate;

  const HccAppBar({
    super.key,
    required this.user,
    this.userName,
    this.isDashboard = false,
    this.onSignOut,
    this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDashboard) {
      return AppBar(
        title:
            user != null
                ? Text(
                  'Bienvenido ${user?.email}',
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
          if (user != null)
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed:
                  onSignOut ??
                  () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
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
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Image.asset('assets/images/logo_club.png', height: 60),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  user != null
                      ? Text(
                        userName != null
                            ? 'Hola $userName'.trim()
                            : 'Hola ${user?.email}',
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
                  if (formattedDate != null)
                    Text(
                      formattedDate!,
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
            onPressed:
                onSignOut ??
                () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  }
                },
          ),
        ],
      );
    }
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(isDashboard ? 120.0 : kToolbarHeight);
}
