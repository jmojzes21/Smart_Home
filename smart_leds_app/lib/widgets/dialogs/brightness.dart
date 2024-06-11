import 'package:flutter/material.dart';
import 'package:smart_leds_app/theme.dart';

class BrightnessDialog extends StatelessWidget {
  const BrightnessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: SizedBox(
        width: 500,
        child: _BrightnessControl(),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const BrightnessDialog(),
    );
  }
}

class _BrightnessControl extends StatefulWidget {
  const _BrightnessControl();
  @override
  State<_BrightnessControl> createState() => _BrightnessControlState();
}

class _BrightnessControlState extends State<_BrightnessControl> {
  double brightness = 20;

  @override
  void initState() {
    super.initState();
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
          value: brightness,
          min: 0,
          max: 100,
          onChanged: (value) => setState(() => brightness = value),
        ),
        Center(
          child:
              Text('${brightness.round()} %', style: const TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
