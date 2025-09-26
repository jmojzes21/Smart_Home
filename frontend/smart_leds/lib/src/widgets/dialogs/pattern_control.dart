import 'package:flutter/material.dart';

class PatternControlDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const PatternControlDialog({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: child,
          ),
        ),
      ),
    );
  }
}
