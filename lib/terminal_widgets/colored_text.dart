import 'package:flutter/material.dart';

import '../terminal_theme.dart';

class ColoredText extends StatelessWidget {
  const ColoredText(this.text, {super.key, this.color = Colors.white});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TerminalTheme.of(context).inputStyle.copyWith(color: color),
    );
  }
}