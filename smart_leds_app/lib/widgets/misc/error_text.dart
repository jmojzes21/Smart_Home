import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String data;

  const ErrorText(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        data,
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
}
