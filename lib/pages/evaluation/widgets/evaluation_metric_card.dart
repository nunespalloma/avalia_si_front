import 'package:flutter/material.dart';

class EvaluationMetricCard extends StatelessWidget {
  final String titulo;
  final Widget conteudo;

  const EvaluationMetricCard({
    super.key,
    required this.titulo,
    required this.conteudo,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 108,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E3E3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            conteudo,
            const Spacer(),
          ],
        ),
      ),
    );
  }
}