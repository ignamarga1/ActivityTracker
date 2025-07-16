import 'package:activity_tracker_flutter/components/std_button.dart';
import 'package:activity_tracker_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  var _isObscuredPassword = true;
  var _isObscuredPasswordConfirmation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    SvgPicture.asset(
                      'activity_tracker_logo.svg',
                      width: 65,
                      height: 65,
                      colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 20),

                    // Information text
                    Text(
                      "Regístrate para empezar a hacer un seguimiento de las diferentes actividades que te propongas",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
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
                      decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Correo electrónico"),
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

                        if (value.contains(' ')) {
                          return 'No puede contener espacios en blanco';
                        }
                        return null;
                      },
                      decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Nombre de usuario"),
                    ),
                    const SizedBox(height: 15),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: _isObscuredPassword,
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

                        if (!RegExp(r'[\^$*.\[\]{}()?"!@#%&/\\,><\:;|_~]').hasMatch(value)) {
                          return 'Debe contener al menos un carácter especial';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Contraseña",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObscuredPassword = !_isObscuredPassword;
                            });
                          },
                          icon: _isObscuredPassword ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Confirm password
                    TextFormField(
                      controller: passwordConfirmationController,
                      obscureText: _isObscuredPasswordConfirmation,
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
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObscuredPasswordConfirmation = !_isObscuredPasswordConfirmation;
                            });
                          },
                          icon: _isObscuredPasswordConfirmation
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Sign up button
                    StdButton(
                      text: "Crear cuenta",
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_formKey.currentState!.validate()) {
                          AuthService().signUp(
                            email: emailController.text.trim(),
                            username: usernameController.text.replaceAll(' ', '').toLowerCase(),
                            password: passwordController.text,
                            passwordConfirmation: passwordConfirmationController.text,
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
      ),
    );
  }
}
