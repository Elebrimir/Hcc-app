import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key, required this.homePageContext})
    : super(key: key);

  final BuildContext homePageContext;

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registro'),
      content: Padding(
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
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                          print(
                            'User ${userCredential.user!.email} registered',
                          );
                          Navigator.of(context).pop();
                        } on FirebaseAuthException catch (e) {
                          print('Failed with error code: ${e.message}');
                          ScaffoldMessenger.of(
                            widget.homePageContext,
                          ).showSnackBar(
                            SnackBar(content: Text('Error: ${e.message}')),
                          );
                        }
                      }
                    },
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
