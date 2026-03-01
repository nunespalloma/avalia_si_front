import 'package:flutter/material.dart';
import 'pages/welcome/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

// Raiz do app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AvaliaSI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}
