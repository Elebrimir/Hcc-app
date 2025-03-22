import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/user_model.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, required this.homePageContext});

  final BuildContext homePageContext;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );
        debugPrint('User ${userCredential.user!.email} registered');

        final User? user = userCredential.user;
        if (user != null) {
          await user.sendEmailVerification();
          debugPrint('Email verification sent to ${user.email}');

          final userModel = UserModel(
            email: user.email,
            name: 'Nombre del usuario',
            lastname: 'Apellidos del usuario',
            role: 'user',
            image: '',
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userModel.toFirestore());

          ScaffoldMessenger.of(widget.homePageContext).showSnackBar(
            const SnackBar(
              content: Text('Usuario registrado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          if (mounted) Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('Failed with error code: ${e.message}');
        ScaffoldMessenger.of(widget.homePageContext).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        debugPrint('Error desconocido al registrar o guardar datos: $e');
        ScaffoldMessenger.of(widget.homePageContext).showSnackBar(
          const SnackBar(
            content: Text('Error desconocido al registrar o guardar datos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registro'),
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
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un email';
                      }
                      if (!RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                      ).hasMatch(value)) {
                        return 'Por favor, introduce un email válido';
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
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirma contraseña',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirma la contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        _register();
                      },
                      child: const Text('Registrarse'),
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
