import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String? mensagemSucesso;

  const HomePage({super.key, this.mensagemSucesso});

  @override
  Widget build(BuildContext context) {
    if (mensagemSucesso != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemSucesso!)),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(
        child: Text(
          "Bem-vindo!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}