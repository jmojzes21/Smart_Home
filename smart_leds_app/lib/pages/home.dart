import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/color_patterns.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/dialogs/brightness.dart';
import 'package:smart_leds_app/widgets/dialogs/pattern_control.dart';
import 'package:smart_leds_app/widgets/misc/navigation_drawer.dart';
import 'package:smart_leds_app/widgets/pattern_controls/single_color.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Početna'),
      ),
      drawer: AppNavigationDrawer(),
      floatingActionButton: IconButton.filled(
        padding: EdgeInsets.all(20),
        onPressed: () => BrightnessDialog.show(context),
        icon: Icon(Icons.light_mode, size: 26),
      ),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: _Patterns(),
      ),
    );
  }
}

class _Patterns extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _PatternCard(
          name: 'Jedna boja',
          icon: 'single.png',
          pattern: SingleColorPattern(),
          controlDialog: (p) => SingleColorPatternControl(p),
        ),
        /*
        _PatternCard(
          name: 'Valovi',
          icon: 'waves.png',
          onPrimaryTap: () {},
          onSecondaryTap: () {},
        ),
        _PatternCard(
          name: 'Dugine boje',
          icon: 'rainbow.png',
          onPrimaryTap: () {},
          onSecondaryTap: () {},
        ),
        _PatternCard(
          name: 'Pojedina dugina boja',
          icon: 'rainbow_single.png',
          onPrimaryTap: () {},
          onSecondaryTap: () {},
        ),
        _PatternCard(
          name: 'Šarena kiša',
          icon: 'rain.png',
          onPrimaryTap: () {},
          onSecondaryTap: () {},
        ),
        _PatternCard(
          name: 'Kiša',
          icon: 'rain_single.png',
          onPrimaryTap: () {},
          onSecondaryTap: () {},
        ),
        _PatternCard(
          name: 'Ugasi lampice',
          icon: 'clear.png',
          onPrimaryTap: () => clearPattern(),
          onSecondaryTap: () {},
        ),*/
        _RawPatternCard(
          name: 'Ugasi lampice',
          icon: 'clear.png',
          onPrimaryTap: () {
            var patterns = PatternProvider.of(context);
            patterns.clearPattern();
          },
          onSecondaryTap: () {},
        ),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  final String name;
  final String icon;
  final ColorPattern pattern;
  final Widget Function(ColorPattern p) controlDialog;

  const _PatternCard({
    required this.name,
    required this.icon,
    required this.pattern,
    required this.controlDialog,
  });

  void showPattern(BuildContext context) {
    var patterns = PatternProvider.of(context);
    patterns.showPattern(pattern);
  }

  void showControlDialog({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return PatternControlDialog(title: title, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _RawPatternCard(
      name: name,
      icon: icon,
      onPrimaryTap: () => showPattern(context),
      onSecondaryTap: () => showControlDialog(
        context: context,
        title: name,
        child: controlDialog(pattern),
      ),
    );
  }
}

class _RawPatternCard extends StatelessWidget {
  final String name;
  final String icon;
  final void Function() onPrimaryTap;
  final void Function() onSecondaryTap;

  const _RawPatternCard({
    required this.name,
    required this.icon,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPrimaryTap,
      onSecondaryTap: onSecondaryTap,
      onLongPress: onSecondaryTap,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/patterns/$icon',
              width: 100,
              height: 100,
              filterQuality: FilterQuality.medium,
            ),
            Text(name, style: MyTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
