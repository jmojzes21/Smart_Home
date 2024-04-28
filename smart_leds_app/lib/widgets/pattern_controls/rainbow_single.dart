import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/widgets/pattern_properties/cspeed.dart';

class RainbowSinglePatternControl extends StatefulWidget {
  const RainbowSinglePatternControl({super.key});
  @override
  State<RainbowSinglePatternControl> createState() =>
      _RainbowSinglePatternControlState();
}

class _RainbowSinglePatternControlState
    extends State<RainbowSinglePatternControl> {
  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.of(context);
    var properties = patternProvider.properties;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CSpeedPropertyWidget(
          cspeed: properties.cSpeed,
          onChange: (value) {
            setState(() {
              properties.cSpeed = value;
              patternProvider.updatePattern();
            });
          },
        ),
      ],
    );
  }
}
