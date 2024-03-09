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
