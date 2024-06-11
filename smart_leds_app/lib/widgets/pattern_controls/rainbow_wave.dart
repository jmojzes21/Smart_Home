import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/widgets/pattern_properties/cspeed.dart';
import 'package:smart_leds_app/widgets/pattern_properties/dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/rspeed.dart';
import 'package:smart_leds_app/widgets/pattern_properties/size.dart';
// TODO izmjeni
/*
class RainbowWavePatternControl extends StatefulWidget {
  const RainbowWavePatternControl({super.key});
  @override
  State<RainbowWavePatternControl> createState() =>
      _RainbowWavePatternControlState();
}

class _RainbowWavePatternControlState extends State<RainbowWavePatternControl> {
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
        const SizedBox(height: 20),
        CSpeedPropertyWidget(
          cspeed: properties.cSpeed,
          onChange: (value) {
            setState(() {
              properties.cSpeed = value;
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
*/