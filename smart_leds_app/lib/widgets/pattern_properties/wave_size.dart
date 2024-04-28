import 'package:flutter/material.dart';
import 'package:smart_leds_app/theme.dart';

class WaveSizeProperty extends StatelessWidget {
  final int size;
  final void Function(int value) onChange;

  const WaveSizeProperty({
    super.key,
    required this.size,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Veličina vala', style: MyTheme.patternPropertyTitle),
        const SizedBox(height: 10),
        SegmentedButton<int>(
          segments: [
            ButtonSegment(
              value: 1,
              label: Text('Mali'),
            ),
            ButtonSegment(
              value: 2,
              label: Text('Srednji'),
            ),
            ButtonSegment(
              value: 3,
              label: Text('Veliki'),
            ),
          ],
          selected: {size},
          onSelectionChanged: (e) => onChange(e.first),
        ),
      ],
    );
  }
}
