import 'package:flutter/material.dart';
import 'package:smart_leds_app/theme.dart';

class ColorPropertyWidget extends StatelessWidget {
  final List<Color> colors = Colors.primaries;
  final void Function(Color color) onColor;

  const ColorPropertyWidget({super.key, required this.onColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Boja', style: MyTheme.patternPropertyTitle),
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
                child: SizedBox.square(
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
