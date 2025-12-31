import 'package:flutter/material.dart';

class MetricsCard extends StatelessWidget {
  final Widget image;
  final Widget title;
  final Widget value;
  final double padding;
  final double imageSpacing;

  const MetricsCard({
    super.key,
    required this.image,
    required this.title,
    required this.value,
    this.padding = 10,
    this.imageSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: imageSpacing,
          children: [
            image,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, value],
            ),
          ],
        ),
      ),
    );
  }
}
