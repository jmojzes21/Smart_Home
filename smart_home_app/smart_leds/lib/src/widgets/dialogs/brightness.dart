import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_core/device.dart';
import '../../logic/device/device.dart';
import '../../models/smart_leds_device_context.dart';
import '../../theme.dart';

class BrightnessDialog extends StatelessWidget {
  const BrightnessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 500,
        child: Consumer<DeviceManager>(
          builder: (context, model, child) {
            var deviceContext = model.deviceContext as SmartLedsDeviceContext;
            return _BrightnessControl(deviceContext);
          },
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(context: context, barrierDismissible: true, builder: (context) => const BrightnessDialog());
  }
}

class _BrightnessControl extends StatefulWidget {
  final SmartLedsDeviceContext deviceContext;
  const _BrightnessControl(this.deviceContext);
  @override
  State<_BrightnessControl> createState() => _BrightnessControlState();
}

class _BrightnessControlState extends State<_BrightnessControl> {
  late DeviceClient device;
  double brightnessPercent = 0;

  @override
  void initState() {
    super.initState();
    device = widget.deviceContext.deviceClient;

    brightnessPercent = device.leds.brightness / 255;
  }

  void setBrightness(double brightnessPercent) {
    int brightness = (brightnessPercent * 255).round();
    device.leds.setBrightness(brightness);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Jačina svjetla', style: MyTheme.titleLarge),
        const SizedBox(height: 10),
        Slider(
          value: brightnessPercent,
          min: 0,
          max: 1,
          onChanged: (value) => setState(() => brightnessPercent = value),
          onChangeEnd: (value) => setBrightness(value),
        ),
        Center(child: Text('${(brightnessPercent * 100).round()} %', style: const TextStyle(fontSize: 20))),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
