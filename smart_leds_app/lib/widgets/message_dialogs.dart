import 'package:flutter/material.dart';

void showMessageDialog(BuildContext context, String title, String body) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Ok'),
        ),
      ],
    ),
  );
}

Future<bool> showConfirmDialog(
    BuildContext context, String title, String body) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Da'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Ne'),
        ),
      ],
    ),
  );

  return result ?? false;
}
