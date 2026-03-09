import 'package:flutter/material.dart';

class MatriculaField extends StatelessWidget {
  final TextEditingController controller;

  const MatriculaField({
    super.key,
    required this.controller,
  });

  InputDecoration buildDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: false,
      labelStyle: const TextStyle(
        color: Colors.black45,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black54),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      cursorColor: Colors.black,
      decoration: buildDecoration('Matrícula'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe sua matrícula';
        }
        return null;
      },
    );
  }
}