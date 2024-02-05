import 'package:flutter/material.dart';

/*
 * Shortcut for creating ListView menus.
 */

Widget jylsListMenu({List<Widget> children = const <Widget>[]}) {
  const double menuWidth = 400;
  return Center(
      child: Container(
          margin: const EdgeInsets.only(top: 32),
          width: menuWidth,
          child: ListView(
            children: children,
          )));
}
