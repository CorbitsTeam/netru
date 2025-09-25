import 'package:flutter/material.dart';

enum ValidationType { error, success, warning, loading }

class ValidationMessageWidget extends StatelessWidget {
  final String message;
  final ValidationType type;

  const ValidationMessageWidget({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          Icon(_getIcon(), color: _getIconColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (type == ValidationType.loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ValidationType.error:
        return Colors.red[50]!;
      case ValidationType.success:
        return Colors.green[50]!;
      case ValidationType.warning:
        return Colors.orange[50]!;
      case ValidationType.loading:
        return Colors.blue[50]!;
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case ValidationType.error:
        return Colors.red[200]!;
      case ValidationType.success:
        return Colors.green[200]!;
      case ValidationType.warning:
        return Colors.orange[200]!;
      case ValidationType.loading:
        return Colors.blue[200]!;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case ValidationType.error:
        return Colors.red[600]!;
      case ValidationType.success:
        return Colors.green[600]!;
      case ValidationType.warning:
        return Colors.orange[600]!;
      case ValidationType.loading:
        return Colors.blue[600]!;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ValidationType.error:
        return Colors.red[800]!;
      case ValidationType.success:
        return Colors.green[800]!;
      case ValidationType.warning:
        return Colors.orange[800]!;
      case ValidationType.loading:
        return Colors.blue[800]!;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ValidationType.error:
        return Icons.error_outline;
      case ValidationType.success:
        return Icons.check_circle_outline;
      case ValidationType.warning:
        return Icons.warning_outlined;
      case ValidationType.loading:
        return Icons.info_outline;
    }
  }
}
