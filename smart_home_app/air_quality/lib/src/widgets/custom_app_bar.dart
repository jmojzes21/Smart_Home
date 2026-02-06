import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({super.key, super.title}) : super(actions: [_AppBarMenu()]);
}

class _AppBarMenu extends StatelessWidget {
  const _AppBarMenu();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => context.go('/'),
          leadingIcon: Icon(Icons.exit_to_app),
          child: Text('Zatvori uređaj'),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(Icons.more_vert),
        );
      },
    );
  }
}
