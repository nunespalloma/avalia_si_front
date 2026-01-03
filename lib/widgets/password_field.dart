import 'package:flutter/material.dart';

/// Campo de senha como componente (stateless, recebe estado por props)
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool senhaVisivel;
  final VoidCallback onToggleSenhaVisivel;

  const PasswordField({
    super.key,
    required this.controller,
    required this.senhaVisivel,
    required this.onToggleSenhaVisivel,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Senha',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            senhaVisivel ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: onToggleSenhaVisivel,
        ),
      ),
      obscureText: !senhaVisivel,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe a senha';
        }
        if (value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
    );
  }
}
