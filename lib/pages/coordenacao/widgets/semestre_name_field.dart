import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SemesterNameField extends StatelessWidget {
  final TextEditingController controller;

  const SemesterNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        _SemestreInputFormatter(),
      ],
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Ex.: 2026.1',
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black38,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _SemestreInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final apenasNumeros = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    String textoFormatado = apenasNumeros;

    if (apenasNumeros.length > 4) {
      textoFormatado =
          '${apenasNumeros.substring(0, 4)}.${apenasNumeros.substring(4)}';
    }

    if (textoFormatado.length > 6) {
      textoFormatado = textoFormatado.substring(0, 6);
    }

    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}