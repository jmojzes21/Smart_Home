import 'package:flutter/material.dart';
import '../../logic/providers/pattern_provider.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/property_values.dart';
import '../misc/simple_color_picker.dart';

class SingleColorPatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const SingleColorPatternControl(this.pattern, {super.key});

  @override
  State<SingleColorPatternControl> createState() => _SingleColorPatternControlState();
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
