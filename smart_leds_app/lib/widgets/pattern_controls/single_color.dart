import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/color_patterns.dart';
import 'package:smart_leds_app/widgets/pattern_properties/color.dart';

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
        ColorPropertyWidget(
          onColor: (color) {
            properties.color = color;
            patternProvider.showPattern(widget.pattern);
          },
        ),
      ],
    );
  }
}
