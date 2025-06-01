import 'package:activity_tracker_flutter/components/std_button.dart';
import 'package:activity_tracker_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),

            // Form
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App name
                  Text("Activity Tracker", style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),

                  // Information text
                  Text(
                    "Regístrate para poder empezar a hacer un seguimiento de las diferentes actividades que te propongas",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: emailController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo es obligatorio';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Correo electrónico",
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Username
                  TextFormField(
                    controller: usernameController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo es obligatorio';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Nombre de usuario",
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo es obligatorio';
                      }

                      if (value.length < 8) {
                        return 'Debe tener al menos 8 caracteres';
                      }

                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Debe contener al menos una letra mayúscula';
                      }

                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Debe contener al menos una letra minúscula';
                      }

                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Debe contener al menos un número';
                      }

                      if (!RegExp(
                        r'[\^$*.\[\]{}()?"!@#%&/\\,><\:;|_~]',
                      ).hasMatch(value)) {
                        return 'Debe contener al menos un carácter especial';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Contraseña",
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Confirm password
                  TextFormField(
                    controller: passwordConfirmationController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo es obligatorio';
                      }

                      if (value != passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Confirma la contraseña",
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Sign up button
                  StdButton(
                    text: "Crear cuenta",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        AuthService().signUp(
                          email: emailController.text,
                          username: usernameController.text,
                          password: passwordController.text,
                          passwordConfirmation:
                              passwordConfirmationController.text,
                          context: context,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 70),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("¿Ya tienes una cuenta? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Inicia sesión",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
