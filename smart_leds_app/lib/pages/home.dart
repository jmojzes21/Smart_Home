import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/models/patterns/color_patterns.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/dialogs/brightness.dart';
import 'package:smart_leds_app/widgets/dialogs/pattern_control.dart';
import 'package:smart_leds_app/widgets/misc/navigation_drawer.dart';
import 'package:smart_leds_app/widgets/pattern_controls/single_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

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

  @override
  void dispose() {
    super.dispose();
  }
}

class _Patterns extends StatefulWidget {
  const _Patterns();
  @override
  State<_Patterns> createState() => __PatternsState();
}

class __PatternsState extends State<_Patterns> {
  @override
  void initState() {
    super.initState();
  }

  void showPattern(ColorPattern pattern) {
    var patterns = PatternProvider.of(context);
    patterns.showPattern(pattern);
  }

  void clearPattern() {
    var patterns = PatternProvider.of(context);
    patterns.clearPattern();
  }

  void showControlDialog({required String title, required Widget child}) {
    showDialog(
      context: context,
      builder: (context) {
        return PatternControlDialog(title: title, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _PatternCard(
          name: 'Jedna boja',
          icon: 'single.png',
          onPrimaryTap: () => showPattern(SingleColorPattern()),
          onSecondaryTap: () => showControlDialog(
            title: 'Jedna boja',
            child: SingleColorPatternControl(),
          ),
        ),
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
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _PatternCard extends StatelessWidget {
  final String name;
  final String icon;
  final void Function() onPrimaryTap;
  final void Function() onSecondaryTap;

  const _PatternCard({
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
