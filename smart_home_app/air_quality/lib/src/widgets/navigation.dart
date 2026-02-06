import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AppNavigation extends StatelessWidget {
  static final List<String> _pages = ['/aq/home', '/aq/data', '/aq/settings'];

  static int getPageIndex(String path) {
    for (int i = 0; i < _pages.length; i++) {
      if (path.startsWith(_pages[i])) {
        return i;
      }
    }
    return 0;
  }

  final int selectedIndex;

  const AppNavigation({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (value) {
        context.go(_pages[value]);
      },
      destinations: [
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.wind), label: 'Kvaliteta zraka'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.chartLine), label: 'Mjerenja'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.gear), label: 'Postavke'),
      ],
    );
  }
}
