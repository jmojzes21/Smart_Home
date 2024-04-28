import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/single_color.dart';
import 'package:smart_leds_app/widgets/pattern_properties/color.dart';

class SingleColorPatternControl extends StatefulWidget {
  const SingleColorPatternControl({super.key});
  @override
  State<SingleColorPatternControl> createState() =>
      _SingleColorPatternControlState();
}

class _SingleColorPatternControlState extends State<SingleColorPatternControl> {
  late SingleColorPattern pattern;

  @override
  void initState() {
    super.initState();
    var patternProvider = PatternProvider.of(context);
    pattern = patternProvider.singleColorPattern;
  }

  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PatternColorProperty(
          onColor: (color) {
            pattern.color = color;
            patternProvider.showPattern(pattern);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
