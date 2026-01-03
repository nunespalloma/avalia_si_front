import 'package:flutter/material.dart';
import 'login_form.dart'; // está na mesma pasta: pages/

/// Tela (page) que cuida só do Scaffold e estrutura geral
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: LoginForm(), // componente com o formulário
        ),
      ),
    );
  }
}
