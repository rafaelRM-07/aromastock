import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool enabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? prefixText;
  final Widget?
  prefixWidget; // Widget adicional opcional (ej. selector o bandera)
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixText,
    this.prefixWidget,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    // Construcción limpia del prefixIcon combinando el icono base y el widget opcional
    Widget? computedPrefixIcon;
    if (prefixWidget != null) {
      computedPrefixIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              icon,
              color: enabled ? const Color(0xFF6A1B29) : Colors.grey,
            ),
          ),
          prefixWidget!,
        ],
      );
    } else {
      computedPrefixIcon = Icon(
        icon,
        color: enabled ? const Color(0xFF6A1B29) : Colors.grey,
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      cursorColor: const Color(0xFF6A1B29),
      style: TextStyle(color: enabled ? Colors.black87 : Colors.grey.shade600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? Colors.grey : Colors.grey.shade500,
        ),
        prefixIcon: computedPrefixIcon,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: enabled ? Colors.black87 : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        counterText:
            '', // Oculta el contador por defecto para mantener el diseño limpio
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A1B29), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      ),
    );
  }
}
