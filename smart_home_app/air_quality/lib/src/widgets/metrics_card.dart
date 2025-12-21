import 'package:flutter/material.dart';

class MetricsCard extends StatelessWidget {
  final Widget image;
  final Widget title;
  final Widget value;

  const MetricsCard({super.key, required this.image, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            image,
            SizedBox(width: 20),
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [title, value]),
          ],
        ),
      ),
    );
  }
}
