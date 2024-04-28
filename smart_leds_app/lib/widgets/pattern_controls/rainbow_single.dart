import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/rainbow_single.dart';
import 'package:smart_leds_app/widgets/pattern_properties/rainbow_cspeed.dart';

class RainbowSinglePatternControl extends StatefulWidget {
  const RainbowSinglePatternControl({super.key});
  @override
  State<RainbowSinglePatternControl> createState() =>
      _RainbowSinglePatternControlState();
}

class _RainbowSinglePatternControlState
    extends State<RainbowSinglePatternControl> {
  late RainbowSinglePattern pattern;

  @override
  void initState() {
    super.initState();
    var patternProvider = PatternProvider.of(context);
    pattern = patternProvider.rainbowSinglePattern;
  }

  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RainbowCSpeedProperty(
          cspeed: pattern.cspeed,
          onChange: (value) {
            setState(() {
              pattern.cspeed = value;
              patternProvider.showPattern(pattern);
            });
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
