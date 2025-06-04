import 'package:activity_tracker_flutter/components/std_button.dart';
import 'package:activity_tracker_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),

            // Form
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App name
                    Text("Activity Tracker", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                
                    // Information text
                    Text(
                      "¿Has olvidado tu contraseña? \n Introduce tu dirección de correo electrónico para que te enviemos un enlace desde el que podrás restablecer tu contraseña",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    const SizedBox(height: 30),
                
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
                
                    StdButton(
                      text: "Enviar enlace",
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_formKey.currentState!.validate()) {
                          AuthService().resetPassword(
                            email: emailController.text,
                            context: context,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
