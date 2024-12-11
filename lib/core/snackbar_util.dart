import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }
}
