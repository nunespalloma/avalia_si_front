import 'package:flutter/material.dart';

class ConfirmPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController senhaController;
  final bool senhaVisivel;
  final VoidCallback onToggleSenhaVisivel;

  const ConfirmPasswordField({
    super.key,
    required this.controller,
    required this.senhaController,
    required this.senhaVisivel,
    required this.onToggleSenhaVisivel,
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
      obscureText: !senhaVisivel,
      cursorColor: Colors.black,
      decoration: buildDecoration('Confirme a senha').copyWith(
        suffixIcon: IconButton(
          onPressed: onToggleSenhaVisivel,
          icon: Icon(
            senhaVisivel ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: Colors.black54,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirme sua senha';
        }
        if (value != senhaController.text) {
          return 'As senhas não coincidem';
        }
        return null;
      },
    );
  }
}