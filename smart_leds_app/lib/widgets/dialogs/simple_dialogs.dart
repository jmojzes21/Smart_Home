import 'package:flutter/material.dart';

class SimpleDialogs {
  static void showMessage(
      {required BuildContext context,
      required String title,
      required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirm(
      {required BuildContext context,
      required String title,
      required String message}) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Ne'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Da'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
