import 'package:flutter/material.dart';

class EvaluationCommentCard extends StatelessWidget {
  final String texto;

  const EvaluationCommentCard({
    super.key,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontFamily: 'DancingScript',
          height: 1.4,
        ),
      ),
    );
  }
}