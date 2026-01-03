import 'package:flutter/material.dart';

/// Botão de login como componente
class LoginButton extends StatelessWidget {
  final bool carregando;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.carregando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        child: carregando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Entrar'),
      ),
    );
  }
}
