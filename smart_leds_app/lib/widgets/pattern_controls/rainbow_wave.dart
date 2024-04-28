import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/rainbow_wave.dart';
import 'package:smart_leds_app/widgets/pattern_properties/rainbow_cspeed.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_rspeed.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_size.dart';

class RainbowWavePatternControl extends StatefulWidget {
  const RainbowWavePatternControl({super.key});
  @override
  State<RainbowWavePatternControl> createState() =>
      _RainbowWavePatternControlState();
}

class _RainbowWavePatternControlState extends State<RainbowWavePatternControl> {
  late RainbowWavePattern pattern;

  @override
  void initState() {
    super.initState();
    var patternProvider = PatternProvider.of(context);
    pattern = patternProvider.rainbowWavePattern;
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
        const SizedBox(height: 20),
        RainbowCSpeedProperty(
          cspeed: pattern.cspeed,
          onChange: (value) {
            setState(() {
              pattern.cspeed = value;
              patternProvider.showPattern(pattern);
            });
          },
        ),
        const SizedBox(height: 20),
        WaveSizeProperty(
          size: pattern.size,
          onChange: (value) {
            setState(() {
              pattern.size = value;
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
