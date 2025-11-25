import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String? subTitle;
  final String link;
  final bool? isPush;
  final IconData icon;
  final Widget? trailing;

  const MenuItem({
    required this.title,
    this.subTitle,
    required this.link,
    required this.icon,
    this.trailing,
    this.isPush=false,
  });
}

const appMenuItems = <MenuItem>[
  MenuItem(title: 'Home', link: '/', icon: Icons.dashboard),
  /*   MenuItem(title: 'Meter', link: '/test', icon: Icons.water), */
  MenuItem(
    title: 'Registrar lecturas',
    link: '/lecturas',
    icon: Icons.app_registration,
  ),
];
