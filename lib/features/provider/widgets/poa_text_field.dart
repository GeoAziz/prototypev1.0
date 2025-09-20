import 'package:flutter/material.dart';

class PoaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;
  final void Function(String)? onChanged;

  const PoaTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
        hintText: hint,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      onChanged: onChanged,
    );
  }
}
