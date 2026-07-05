import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: backgroundColor ?? AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: duration,
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppTheme.success,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFFB71C1C),
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppTheme.primary,
    );
  }
}
