// lib/widgets/email_field.dart
import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      decoration: const InputDecoration(
        labelText: 'E-mail UFF',
        labelStyle: TextStyle(
          color: Colors.black45,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe o e-mail';
        }
        if (!value.contains('@')) {
          return 'Informe um e-mail válido';
        }
        return null;
      },
    );
  }
}