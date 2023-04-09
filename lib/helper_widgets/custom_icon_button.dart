import 'package:flutter/material.dart';

import '../terminal_theme.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(this.icon, {super.key, required this.onPressed});

  final void Function() onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final style = TerminalTheme.of(context).inputStyle;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Icon(
          icon,
          color: style.color,
          size: style.fontSize,
        ),
      ),
    );
  }
}