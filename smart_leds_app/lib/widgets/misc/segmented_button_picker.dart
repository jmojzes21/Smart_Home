import 'package:flutter/material.dart';
import 'package:smart_leds_app/theme.dart';

class SegmentedButtonPicker<T> extends StatelessWidget {
  final String label;
  final T value;

  final List<({T value, String label})> values;
  final void Function(T value) onChange;

  const SegmentedButtonPicker({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MyTheme.patternPropertyTitle),
        const SizedBox(height: 10),
        SegmentedButton<T>(
          segments:
              values.map((e) => toButtonSegment(e.value, e.label)).toList(),
          selected: {value},
          onSelectionChanged: (e) => onChange(e.first),
        ),
      ],
    );
  }

  ButtonSegment<T> toButtonSegment(T value, String label) {
    return ButtonSegment<T>(value: value, label: Text(label));
  }
}
