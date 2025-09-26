import 'package:flutter/material.dart';
import 'package:smart_leds_app/widgets/misc/checkbox.dart';

class SimpleDialogs {
  static Future<void> showMessage(
      {required BuildContext context,
      required String title,
      required String message,
      bool barrierDismissible = true}) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
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
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Da'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  static Future<bool> showExtraConfirm({
    required BuildContext context,
    required String title,
    required String message,
    required String checkboxText,
  }) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _ExtraConfirmDialog(title, message, checkboxText);
      },
    );

    return result ?? false;
  }
}

class _ExtraConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String checkboxText;

  const _ExtraConfirmDialog(this.title, this.message, this.checkboxText);
  @override
  State<_ExtraConfirmDialog> createState() => _ExtraConfirmDialogState();
}

class _ExtraConfirmDialogState extends State<_ExtraConfirmDialog> {
  bool isChecked = false;

  void confirm() {
    if (isChecked) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message),
          const SizedBox(height: 10),
          CheckboxText(
            value: isChecked,
            text: widget.checkboxText,
            onChanged: (value) => setState(() => isChecked = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ne'),
        ),
        TextButton(
          onPressed: isChecked ? confirm : null,
          child: const Text('Da'),
        ),
      ],
    );
  }
}
