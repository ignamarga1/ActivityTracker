import 'package:flutter/material.dart';

class StdTextfield extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const StdTextfield({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (value) {
        if(value == null || value.isEmpty) {
          return 'El campo es obligatorio';
        } 
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
      ),
    );
  }
}
