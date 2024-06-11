import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/widgets/pattern_properties/dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/rspeed.dart';
/*
class RainbowPatternControl extends StatefulWidget {
  const RainbowPatternControl({super.key});
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
        DirPropertyWidget(
          dir: properties.dir,
          onChange: (value) {
            setState(() {
              properties.dir = value;
              patternProvider.updatePattern();
            });
          },
        ),
        const SizedBox(height: 20),
        RSpeedPropertyWidget(
          rspeed: properties.rSpeed,
          onChange: (value) {
            setState(() {
              properties.rSpeed = value;
              patternProvider.updatePattern();
            });
          },
        ),
      ],
    );
  }
}
*/