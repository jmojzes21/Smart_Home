import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/patterns.dart';
import 'package:smart_leds_app/models/patterns/property_values.dart';
import 'package:smart_leds_app/widgets/misc/segmented_button_picker.dart';
import 'package:smart_leds_app/widgets/misc/simple_color_picker.dart';
import 'package:smart_leds_app/widgets/pattern_properties/dir.dart';
import 'package:smart_leds_app/widgets/pattern_properties/rspeed.dart';
import 'package:smart_leds_app/widgets/pattern_properties/size.dart';

class WavePatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const WavePatternControl(this.pattern, {super.key});

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
        SimpleColorPicker(
          colors: PatternPropertyValues.basicColors,
          onColor: (color) {
            properties.color = color;
            patternProvider.showPattern(widget.pattern);
          },
        ),
        const SizedBox(height: 20),
        SegmentedButtonPicker(
          label: 'Brzina promjene',
          value: properties.waveSpeed,
          values: PatternPropertyValues.waveSpeedValues,
          onChange: (value) => setState(() {
            properties.waveSpeed = value;
            patternProvider.showPattern(widget.pattern);
          }),
        ),
        /*const SizedBox(height: 20),
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
        ),*/
      ],
    );
  }
}
