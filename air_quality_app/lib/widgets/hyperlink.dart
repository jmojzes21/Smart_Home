import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Hyperlink extends StatefulWidget {
  final String text;
  final String url;

  const Hyperlink({super.key, required this.text, required this.url});

  @override
  State<Hyperlink> createState() => _HyperlinkState();
}

class _HyperlinkState extends State<Hyperlink> {
  var recognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    recognizer.onTap = () => launchUrlString(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(color: Colors.blue),
        recognizer: recognizer,
      ),
    );
  }

  @override
  void dispose() {
    recognizer.dispose();
    super.dispose();
  }
}
