import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../terminal_theme.dart';

class InputRow extends StatefulWidget {
  const InputRow({super.key, this.prefix, required this.onEnterPressed, this.isVisible = true, this.maxLines = 1});

  final Widget? prefix;
  final void Function(BuildContext context, String input) onEnterPressed;
  final bool isVisible;
  final int? maxLines;

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
        if (widget.prefix != null) widget.prefix!,
        Expanded(
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (value) {
              const enterId = 0x10000000d;
              if (value is KeyUpEvent && value.logicalKey.keyId == enterId && widget.maxLines != 1) {
                widget.onEnterPressed(context, controller.text);
              }
            },
            child: EditableText(
              onSubmitted: (text) {
                widget.onEnterPressed(context, controller.text);
              },
              obscureText: !widget.isVisible,
              maxLines: widget.maxLines,
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
