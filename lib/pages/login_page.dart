import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hcc_app/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.homePageContext});

  final BuildContext homePageContext;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(widget.homePageContext).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce un email')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      ScaffoldMessenger.of(widget.homePageContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Se ha enviado un email para restablecer la contraseña',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to send password reset email: ${e.message}');
      ScaffoldMessenger.of(
        widget.homePageContext,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Acceso'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce una contraseña';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final userCredential = await FirebaseAuth
                                    .instance
                                    .signInWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                debugPrint(
                                  'User ${userCredential.user!.email} logged in',
                                );
                                if (mounted) Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  widget.homePageContext,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardPage(),
                                  ),
                                );
                              } on FirebaseAuthException catch (e) {
                                debugPrint('Failed to log in: ${e.message}');
                                if (mounted) {
                                  ScaffoldMessenger.of(
                                    widget.homePageContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.message}'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text('Acceder'),
                        ),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text('¿Olvidaste la contraseña?'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
