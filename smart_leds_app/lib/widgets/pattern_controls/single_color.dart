import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/patterns.dart';
import 'package:smart_leds_app/models/patterns/property_values.dart';
import 'package:smart_leds_app/widgets/misc/simple_color_picker.dart';

class SingleColorPatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const SingleColorPatternControl(this.pattern, {super.key});

  @override
  State<SingleColorPatternControl> createState() =>
      _SingleColorPatternControlState();
}

class _SingleColorPatternControlState extends State<SingleColorPatternControl> {
  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.of(context);
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
            patternProvider.showPattern(widget.pattern);
          }),
        ),
      ],
    );
  }
}
