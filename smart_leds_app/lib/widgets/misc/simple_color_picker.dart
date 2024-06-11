import 'package:flutter/material.dart';
import 'package:smart_leds_app/theme.dart';

class SimpleColorPicker extends StatelessWidget {
  final List<Color> colors;
  final void Function(Color color) onColor;

  const SimpleColorPicker({
    super.key,
    required this.colors,
    required this.onColor,
  });

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
          children: colors.map((e) {
            return Material(
              color: e,
              child: InkWell(
                splashColor: e,
                onTap: () => onColor(e),
                child: const SizedBox.square(
                  dimension: 50,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
