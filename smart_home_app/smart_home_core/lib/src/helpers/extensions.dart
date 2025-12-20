import 'package:flutter/material.dart';

extension BuildContextHelper on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
