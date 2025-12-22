import 'package:flutter/material.dart';
import '../../logic/providers/pattern_provider.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/property_values.dart';
import '../misc/segmented_button_picker.dart';

class RainbowPatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const RainbowPatternControl(this.pattern, {super.key});

  @override
  State<RainbowPatternControl> createState() => _RainbowPatternControlState();
}

class _RainbowPatternControlState extends State<RainbowPatternControl> {
  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.instance!;
    var properties = patternProvider.properties;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButtonPicker(
          label: 'Brzina promjene',
          value: properties.rainbowSpeed,
          values: PatternPropertyValues.rainbowSpeedValues,
          onChange: (value) => setState(() {
            properties.rainbowSpeed = value;
            patternProvider.showPattern(widget.pattern);
          }),
        ),
      ],
    );
  }
}
