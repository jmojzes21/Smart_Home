import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/patterns.dart';
import 'package:smart_leds_app/models/patterns/property_values.dart';
import 'package:smart_leds_app/widgets/misc/segmented_button_picker.dart';
import 'package:smart_leds_app/widgets/pattern_properties/dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/rspeed.dart';

class RainbowPatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const RainbowPatternControl(this.pattern, {super.key});

  @override
  State<RainbowPatternControl> createState() => _RainbowPatternControlState();
}

class _RainbowPatternControlState extends State<RainbowPatternControl> {
  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.of(context);
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
            properties.waveSpeed = value;
            patternProvider.showPattern(widget.pattern);
          }),
        ),
      ],
    );
  }
}
