import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showLocationSnack(
  String msg, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  Get.snackbar(
    'Notice',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.black.withValues(alpha: 0.85),
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
    mainButton: (actionLabel != null && onAction != null)
        ? TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(color: Colors.white),
            ),
          )
        : null,
  );
}
