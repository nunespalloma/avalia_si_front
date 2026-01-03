import 'package:flutter/material.dart';
import 'services/auth_service.dart';       // caso precise em outros lugares depois
import 'pages/login/login_page.dart';   // nossa tela de login

void main() {
  runApp(const MyApp());
}

// Raiz do app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
