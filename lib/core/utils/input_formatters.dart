import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Apply Safaricom format (e.g., 712 345 678)
    if (newText.length > 3) {
      newText = '${newText.substring(0, 3)} ${newText.substring(3)}';
    }
    if (newText.length > 7) {
      newText = '${newText.substring(0, 7)} ${newText.substring(7)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
