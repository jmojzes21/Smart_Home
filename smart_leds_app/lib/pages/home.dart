import 'package:flutter/material.dart';
import 'package:smart_leds_app/logic/providers/pattern_provider.dart';
import 'package:smart_leds_app/theme.dart';
import 'package:smart_leds_app/widgets/navigation_drawer.dart';

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
      body: buildBody(),
    );
  }

  Widget buildBody() {
    var patterns = PatternProvider.of(context);

    return Padding(
      padding: EdgeInsets.all(40),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          _PatternCard(
            name: 'Jednobojno',
            icon: 'pattern_single.png',
            onPrimaryTap: () =>
                patterns.showPattern(patterns.singleColorPattern),
            onSecondaryTap: () {},
          ),
          _PatternCard(
            name: 'Jednobojni val',
            icon: 'pattern_wave.png',
            onPrimaryTap: () => patterns.showPattern(patterns.wavePattern),
            onSecondaryTap: () {},
          ),
          _PatternCard(
            name: 'Dugine boje',
            icon: 'pattern_rainbow.png',
            onPrimaryTap: () => patterns.showPattern(patterns.rainbowPattern),
            onSecondaryTap: () {},
          ),
          _PatternCard(
            name: 'Pojedina dugina boja',
            icon: 'pattern_rainbow_single.png',
            onPrimaryTap: () =>
                patterns.showPattern(patterns.rainbowSinglePattern),
            onSecondaryTap: () {},
          ),
          _PatternCard(
            name: 'Val duginih boja',
            icon: 'pattern_rainbow_wave.png',
            onPrimaryTap: () =>
                patterns.showPattern(patterns.rainbowWavePattern),
            onSecondaryTap: () {},
          ),
          _PatternCard(
            name: 'Bez uzorka',
            icon: 'pattern_none.png',
            onPrimaryTap: () => patterns.clearPattern(),
            onSecondaryTap: () {},
          ),
        ],
      ),
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
    super.key,
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
              'assets/icons/$icon',
              width: 100,
              height: 100,
              filterQuality: FilterQuality.medium,
            ),
            SizedBox(height: 10),
            Text(name, style: MyTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
