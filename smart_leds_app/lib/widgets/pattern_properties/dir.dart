import 'package:flutter/material.dart';
import 'package:smart_leds_app/theme.dart';

class DirPropertyWidget extends StatelessWidget {
  final int dir;
  final void Function(int value) onChange;

  const DirPropertyWidget({
    super.key,
    required this.dir,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Smjer', style: MyTheme.patternPropertyTitle),
        const SizedBox(height: 10),
        SegmentedButton<int>(
          segments: [
            ButtonSegment(
              value: -1,
              label: Text('Lijevo'),
            ),
            ButtonSegment(
              value: 1,
              label: Text('Desno'),
            ),
          ],
          selected: {dir},
          onSelectionChanged: (e) => onChange(e.first),
        ),
      ],
    );
  }
}
