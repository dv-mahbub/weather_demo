import 'package:flutter/material.dart';

void showMessage(BuildContext context, String message,
    [bool? isFloating = false]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior:
          isFloating! ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showSuccessMessage(BuildContext context, String message,
    [bool? isFloating = false]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior:
          isFloating! ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: const Color.fromARGB(255, 9, 112, 12),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showWarningMessage(BuildContext context, String message,
    [bool? isFloating = false]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior:
          isFloating! ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: const Color.fromARGB(255, 253, 214, 95),
      content: Text(
        message,
        style: const TextStyle(color: Colors.black),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showErrorMessage(BuildContext context, String message,
    [bool? isFloating = false]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior:
          isFloating! ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: const Color.fromARGB(255, 207, 19, 6),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
