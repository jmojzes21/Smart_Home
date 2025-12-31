import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Dialogs {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text(message)));
  }

  static Future<bool> showConfirmDialog(BuildContext context, String message) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          FilledButton(onPressed: () => context.pop(true), child: Text('Da')),
          TextButton(onPressed: () => context.pop(false), child: Text('Ne')),
        ],
      ),
    );
    return result == true;
  }
}
