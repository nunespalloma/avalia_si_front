import 'package:flutter/material.dart';
import 'signup_form.dart';
import '../../widgets/signup_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _matriculaController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _toggleSenhaVisivel() {
    setState(() {
      _senhaVisivel = !_senhaVisivel;
    });
  }

  void _toggleConfirmarSenhaVisivel() {
    setState(() {
      _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
    });
  }

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Cadastro válido');
      // TODO: implementar cadastro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 80),

              const Center(
                child: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Seja\nbem-\nvindo(a)!',
                    style: TextStyle(
                      fontFamily: 'Michroma',
                      fontSize: 42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              SignUpForm(
                formKey: _formKey,
                emailController: _emailController,
                matriculaController: _matriculaController,
                senhaController: _senhaController,
                confirmarSenhaController: _confirmarSenhaController,
                senhaVisivel: _senhaVisivel,
                confirmarSenhaVisivel: _confirmarSenhaVisivel,
                onToggleSenhaVisivel: _toggleSenhaVisivel,
                onToggleConfirmarSenhaVisivel: _toggleConfirmarSenhaVisivel,
              ),

              const Spacer(),

              SignUpButton(
                onPressed: () {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );*/
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
