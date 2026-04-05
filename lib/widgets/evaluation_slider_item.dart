import 'package:flutter/material.dart';

class EvaluationSliderItem extends StatelessWidget {
  final String titulo;
  final double valor;
  final ValueChanged<double> onChanged;
  final String labelEsquerda;
  final String labelCentro;
  final String labelDireita;

  const EvaluationSliderItem({
    super.key,
    required this.titulo,
    required this.valor,
    required this.onChanged,
    required this.labelEsquerda,
    required this.labelCentro,
    required this.labelDireita,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: valor,
            min: 0,
            max: 2,
            divisions: 2,
            activeColor: Colors.grey,
            inactiveColor: Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labelEsquerda,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                labelCentro,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                labelDireita,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}