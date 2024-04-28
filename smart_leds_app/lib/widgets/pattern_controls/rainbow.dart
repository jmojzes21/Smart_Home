import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/rainbow.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_rspeed.dart';

class RainbowPatternControl extends StatefulWidget {
  const RainbowPatternControl({super.key});
  @override
  State<RainbowPatternControl> createState() => _RainbowPatternControlState();
}

class _RainbowPatternControlState extends State<RainbowPatternControl> {
  late RainbowPattern pattern;

  @override
  void initState() {
    super.initState();
    var patternProvider = PatternProvider.of(context);
    pattern = patternProvider.rainbowPattern;
  }

  @override
  Widget build(BuildContext context) {
    var patternProvider = PatternProvider.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WaveDirProperty(
          dir: pattern.dir,
          onChange: (value) {
            setState(() {
              pattern.dir = value;
              patternProvider.showPattern(pattern);
            });
          },
        ),
        const SizedBox(height: 20),
        WaveRSpeedProperty(
          rspeed: pattern.rspeed,
          onChange: (value) {
            setState(() {
              pattern.rspeed = value;
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
