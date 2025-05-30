import 'package:activity_tracker_flutter/components/std_button.dart';
import 'package:activity_tracker_flutter/components/std_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final emailUsernameController = TextEditingController();
  final passwordController = TextEditingController();

  final void Function()? onTap;

  LoginPage({super.key, this.onTap});

  // Functions
  void login() {}

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
                const SizedBox(height: 40),
            
                // Email / Username
                StdTextfield(
                  labelText: "Correo electrónico o nombre de usuario",
                  hintText: "",
                  obscureText: false,
                  controller: emailUsernameController,
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
            
                // Forgot your password?
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
            
                // Sign in button
                StdButton(text: "Acceder", onTap: login),
                const SizedBox(height: 70),
            
                // Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("¿No tienes cuenta? "),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        "Regístrate",
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
