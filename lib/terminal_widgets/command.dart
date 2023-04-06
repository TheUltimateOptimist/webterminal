import 'package:flutter/material.dart';

import '../terminal_theme.dart';

class Command extends StatelessWidget {
  const Command({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: ">>> ",
        style: TerminalTheme.of(context).lineStartStyle,
        children: [
          TextSpan(
            text: text ?? "",
            style: TerminalTheme.of(context).inputStyle,
          ),
        ],
      ),
    );
  }
}