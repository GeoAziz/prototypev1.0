import 'app_error.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, Object error) {
    final message = error is AppError ? error.message : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
