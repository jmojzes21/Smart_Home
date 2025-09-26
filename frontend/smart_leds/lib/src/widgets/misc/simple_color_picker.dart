import 'package:flutter/material.dart';
import 'package:smart_leds/src/theme.dart';

class SimpleColorPicker extends StatefulWidget {
  final Color color;
  final List<Color> colors;
  final void Function(Color color) onColor;

  const SimpleColorPicker({super.key, required this.color, required this.colors, required this.onColor});

  @override
  State<SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<SimpleColorPicker> {
  int red = 0;
  int green = 0;
  int blue = 0;

  @override
  void initState() {
    super.initState();

    red = widget.color.red;
    green = widget.color.green;
    blue = widget.color.blue;
  }

  void onColor(Color color) {
    widget.onColor(color);

    setState(() {
      red = color.red;
      green = color.green;
      blue = color.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Boja', style: MyTheme.patternPropertyTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.colors.map((e) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: ClipOval(
                child: Material(
                  color: e,
                  child: InkWell(splashColor: e, onTap: () => onColor(e), child: const SizedBox.square(dimension: 50)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        //
        Text('Crvena: $red', style: MyTheme.bodyMedium),
        Slider(value: red.toDouble(), min: 0, max: 255, onChanged: (value) => setState(() => red = value.round()), onChangeEnd: (value) => onColor(Color.fromARGB(255, red, green, blue))),

        //
        Text('Zelena: $green', style: MyTheme.bodyMedium),
        Slider(value: green.toDouble(), min: 0, max: 255, onChanged: (value) => setState(() => green = value.round()), onChangeEnd: (value) => onColor(Color.fromARGB(255, red, green, blue))),

        //
        Text('Plava: $blue', style: MyTheme.bodyMedium),
        Slider(value: blue.toDouble(), min: 0, max: 255, onChanged: (value) => setState(() => blue = value.round()), onChangeEnd: (value) => onColor(Color.fromARGB(255, red, green, blue))),
      ],
    );
  }
}
