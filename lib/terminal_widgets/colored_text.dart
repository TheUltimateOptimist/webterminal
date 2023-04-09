import 'package:flutter/material.dart';

import '../terminal_theme.dart';

class ColoredText extends StatelessWidget {
  const ColoredText(this.text, {super.key, this.color = Colors.white});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TerminalTheme.of(context).inputStyle.copyWith(color: color);
    return SizedBox(
      height: style.fontSize,//for some reason the text is twice as large if not constrained with sized box to the font size
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
