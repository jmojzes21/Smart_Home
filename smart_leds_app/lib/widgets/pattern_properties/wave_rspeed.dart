import 'package:flutter/material.dart';
import 'package:smart_leds_app/theme.dart';

class WaveRSpeedProperty extends StatelessWidget {
  final int rspeed;
  final void Function(int value) onChange;

  const WaveRSpeedProperty({
    super.key,
    required this.rspeed,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brzina okretanja', style: MyTheme.patternPropertyTitle),
        const SizedBox(height: 10),
        SegmentedButton<int>(
          segments: [
            ButtonSegment(
              value: 30,
              label: Text('Sporo'),
            ),
            ButtonSegment(
              value: 20,
              label: Text('Umjereno'),
            ),
            ButtonSegment(
              value: 10,
              label: Text('Brzo'),
            ),
          ],
          selected: {rspeed},
          onSelectionChanged: (e) => onChange(e.first),
        ),
      ],
    );
  }
}
