import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String? subTitle;
  final String link;
  final IconData icon;
  final Widget? trailing;

  const MenuItem({
    required this.title,
    this.subTitle,
    required this.link,
    required this.icon,
    this.trailing,
  });
}

const appMenuItems = <MenuItem>[
  MenuItem(title: 'Home', link: '/', icon: Icons.home),
  MenuItem(
    title: 'Registrar lecturas',
    link: '/lecturas',
    icon: Icons.event_note,
  ),
];
