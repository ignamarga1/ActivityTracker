import 'package:activity_tracker_flutter/components/std_button.dart';
import 'package:activity_tracker_flutter/components/std_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  void register() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),

          // Form
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App name
                Text("Activity Tracker", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
            
                // Informative text
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
                StdTextfield(
                  labelText: "Correo electrónico",
                  hintText: "",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 15),
            
                // Username
                StdTextfield(
                  labelText: "Nombre de usuario",
                  hintText: "",
                  obscureText: false,
                  controller: usernameController,
                ),
                const SizedBox(height: 15),
            
                // Password
                StdTextfield(
                  labelText: "Contraseña",
                  hintText: "",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 15),
            
                // Confirm password
                StdTextfield(
                  labelText: "Confirma la contraseña",
                  hintText: "",
                  obscureText: true,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 30),
            
                // Sign in button
                StdButton(text: "Acceder", onTap: register),
                const SizedBox(height: 70),
            
                // Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Ya tienes una cuenta? "),
                    GestureDetector(
                      onTap: onTap,
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
    );
  }
}
