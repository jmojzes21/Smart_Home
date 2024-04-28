import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/widgets/pattern_properties/color.dart';
import 'package:smart_leds_app/widgets/pattern_properties/dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/rspeed.dart';
import 'package:smart_leds_app/widgets/pattern_properties/size.dart';

class WavePatternControl extends StatefulWidget {
  const WavePatternControl({super.key});
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
        ColorPropertyWidget(
          onColor: (color) {
            properties.color = color;
            patternProvider.updatePattern();
          },
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 20),
        SizePropertyWidget(
          size: properties.size,
          onChange: (value) {
            setState(() {
              properties.size = value;
              patternProvider.updatePattern();
            });
          },
        ),
      ],
    );
  }
}
