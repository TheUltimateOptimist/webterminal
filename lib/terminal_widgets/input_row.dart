import 'package:flutter/material.dart';
import 'package:statewithease/statewithease.dart';
import 'package:flutter/services.dart';

import '../terminal.dart';
import '../terminal_theme.dart';
import 'command.dart';

class InputRow extends StatefulWidget {
  const InputRow({super.key});

  @override
  State<InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<InputRow> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Command(),
        Expanded(
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (value) {
              const enterId = 0x10000000d;
              if (value is KeyUpEvent && value.logicalKey.keyId == enterId) {
                context.collectOne(commandEntered, controller.text);
              }
            },
            child: EditableText(
              maxLines: null,
              autofocus: true,
              controller: controller,
              backgroundCursorColor: Colors.black,
              cursorColor: Colors.white,
              focusNode: FocusNode(),
              style: TerminalTheme.of(context).inputStyle,
            ),
          ),
        ),
      ],
    );
  }
}