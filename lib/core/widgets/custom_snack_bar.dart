import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

void showModernSnackBar(
  BuildContext context, {
  required String message,
  required SnackBarType type,
}) {
  Color backgroundColor;
  IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      break;
    case SnackBarType.info:
      backgroundColor = Colors.blue;
      icon = Icons.info;
      break;
  }
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      duration: const Duration(seconds: 3),
    ),
  );
}
