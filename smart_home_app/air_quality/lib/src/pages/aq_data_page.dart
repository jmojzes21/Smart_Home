import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_core/extensions.dart';

import '../widgets/custom_app_bar.dart';

class AqDataPage extends StatelessWidget {
  const AqDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = context.textTheme;
    var titleStyle = textTheme.titleMedium;
    return Scaffold(
      appBar: CustomAppBar(title: Text('Mjerenja')),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            ListTile(
              onTap: () => context.go('/aq/data/live'),
              titleTextStyle: titleStyle,
              leading: FaIcon(FontAwesomeIcons.clock),
              title: Text('Uživo podaci'),
              subtitle: Text('Prikaži podatke uživo kako pristižu.'),
            ),
            ListTile(
              onTap: () => context.go('/aq/data/recent'),
              titleTextStyle: titleStyle,
              leading: FaIcon(FontAwesomeIcons.clockRotateLeft),
              title: Text('Nedavni podaci'),
              subtitle: Text('Prikaži nedavne podatke pohranjene lokalno na uređaju.'),
            ),
            ListTile(
              onTap: () => context.go('/aq/data/history'),
              titleTextStyle: titleStyle,
              leading: FaIcon(FontAwesomeIcons.book),
              title: Text('Povijesni podaci'),
              subtitle: Text('Prikaži povijesne podatke pohranjene u bazi podataka.'),
            ),
            ListTile(
              onTap: () {},
              titleTextStyle: titleStyle,
              leading: FaIcon(FontAwesomeIcons.upload),
              title: Text('Učitaj podatke'),
              subtitle: Text('Učitaj podatke iz csv datoteke.'),
            ),
          ],
        ),
      ),
    );
  }
}
