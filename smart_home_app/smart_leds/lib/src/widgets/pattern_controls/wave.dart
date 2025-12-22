import 'package:flutter/material.dart';
import '../../logic/providers/pattern_provider.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/property_values.dart';
import '../misc/segmented_button_picker.dart';
import '../misc/simple_color_picker.dart';

class WavePatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const WavePatternControl(this.pattern, {super.key});

  @override
  State<WavePatternControl> createState() => _WavePatternControlState();
}

class _WavePatternControlState extends State<WavePatternControl> {
  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.instance!;
    var properties = patternProvider.properties;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleColorPicker(
          color: properties.color,
          colors: PatternPropertyValues.basicColors,
          onColor: (color) => setState(() {
            properties.color = color;
            properties.waveChangeColors = false;
            patternProvider.showPattern(widget.pattern);
          }),
        ),
        const SizedBox(height: 20),
        SegmentedButtonPicker(
          label: 'Brzina promjene',
          value: properties.waveSpeed,
          values: PatternPropertyValues.waveSpeedValues,
          onChange: (value) => setState(() {
            properties.waveSpeed = value;
            patternProvider.showPattern(widget.pattern);
          }),
        ),
        const SizedBox(height: 20),
        SegmentedButtonPicker(
          label: 'Način rada',
          value: properties.waveChangeColors,
          values: const [(value: false, label: 'Jednobojno'), (value: true, label: 'Mijenjaj boje')],
          onChange: (value) => setState(() {
            properties.waveChangeColors = value;
            patternProvider.showPattern(widget.pattern);
          }),
        ),
      ],
    );
  }
}
