import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/property_values.dart';
import '../../models/smart_leds_device_context.dart';
import '../misc/segmented_button_picker.dart';

class RainbowPatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const RainbowPatternControl(this.pattern, {super.key});

  @override
  State<RainbowPatternControl> createState() => _RainbowPatternControlState();
}

class _RainbowPatternControlState extends State<RainbowPatternControl> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceManager>(
      builder: (context, model, child) {
        var deviceContext = model.deviceContext as SmartLedsDeviceContext;
        var properties = deviceContext.patternProperties;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButtonPicker(
              label: 'Brzina promjene',
              value: properties.rainbowSpeed,
              values: PatternPropertyValues.rainbowSpeedValues,
              onChange: (value) => setState(() {
                properties.rainbowSpeed = value;
                deviceContext.deviceClient.leds.showPattern(widget.pattern, properties);
              }),
            ),
          ],
        );
      },
    );
  }
}
