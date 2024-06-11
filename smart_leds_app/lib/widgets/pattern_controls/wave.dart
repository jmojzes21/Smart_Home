import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/patterns.dart';
import 'package:smart_leds_app/models/patterns/property_values.dart';
import 'package:smart_leds_app/widgets/misc/segmented_button_picker.dart';
import 'package:smart_leds_app/widgets/misc/simple_color_picker.dart';

class WavePatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const WavePatternControl(this.pattern, {super.key});

  @override
  State<WavePatternControl> createState() => _WavePatternControlState();
}

class _WavePatternControlState extends State<WavePatternControl> {
  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.of(context);
    var properties = patternProvider.properties;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleColorPicker(
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
          values: const [
            (value: false, label: 'Jednobojno'),
            (value: true, label: 'Mijenjaj boje'),
          ],
          onChange: (value) => setState(() {
            properties.waveChangeColors = value;
            patternProvider.showPattern(widget.pattern);
          }),
        ),
      ],
    );
  }
}
