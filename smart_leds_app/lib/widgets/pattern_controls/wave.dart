import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/wave.dart';
import 'package:smart_leds_app/widgets/pattern_properties/color.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_rspeed.dart';
import 'package:smart_leds_app/widgets/pattern_properties/wave_size.dart';

class WavePatternControl extends StatefulWidget {
  const WavePatternControl({super.key});
  @override
  State<WavePatternControl> createState() => _WavePatternControlState();
}

class _WavePatternControlState extends State<WavePatternControl> {
  late WavePattern pattern;

  @override
  void initState() {
    super.initState();
    var patternProvider = PatternProvider.of(context);
    pattern = patternProvider.wavePattern;
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
        const SizedBox(height: 20),
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
