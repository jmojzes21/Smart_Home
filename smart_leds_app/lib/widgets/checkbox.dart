import 'package:flutter/material.dart';

class CheckboxText extends StatelessWidget {
  final bool value;
  final String text;
  final void Function(bool value) onChanged;

  const CheckboxText({
    super.key,
    required this.value,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (bool? value) => onChanged(value ?? false),
        ),
        Text(text),
      ],
    );
  }
}
