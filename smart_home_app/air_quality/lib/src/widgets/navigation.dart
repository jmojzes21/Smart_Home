import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AppNavigation extends StatelessWidget {
  static final List<String> _pages = ['/aq/home', '/aq/settings'];
  static final List<String> _pageTitles = ['Kvaliteta zraka', 'Postavke'];

  static int getPageIndex(String path) {
    for (int i = 0; i < _pages.length; i++) {
      if (path.startsWith(_pages[i])) {
        return i;
      }
    }
    return 0;
  }

  static String getPageTitle(int index) {
    return _pageTitles[index];
  }

  final int selectedIndex;

  const AppNavigation({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (value) {
        if (selectedIndex != value) {
          context.replace(_pages[value]);
        }
      },
      destinations: [
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.wind), label: 'Kvaliteta zraka'),
        NavigationDestination(icon: FaIcon(FontAwesomeIcons.gear), label: 'Postavke'),
      ],
    );
  }
}
