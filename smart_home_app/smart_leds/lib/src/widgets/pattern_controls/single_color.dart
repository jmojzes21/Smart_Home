import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import '../../models/patterns/patterns.dart';
import '../../models/patterns/property_values.dart';
import '../../models/smart_leds_device_context.dart';
import '../misc/simple_color_picker.dart';

class SingleColorPatternControl extends StatefulWidget {
  final ColorPattern pattern;

  const SingleColorPatternControl(this.pattern, {super.key});

  @override
  State<SingleColorPatternControl> createState() => _SingleColorPatternControlState();
}

class _SingleColorPatternControlState extends State<SingleColorPatternControl> {
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
            SimpleColorPicker(
              color: properties.color,
              colors: PatternPropertyValues.basicColors,
              onColor: (color) => setState(() {
                properties.color = color;
                deviceContext.deviceClient.leds.showPattern(widget.pattern, properties);
              }),
            ),
          ],
        );
      },
    );
  }
}
