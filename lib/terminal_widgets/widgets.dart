import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';

import '../output.dart';
import 'colored_text.dart';
import 'pomodoro_timer.dart';
import 'terminal_table.dart';
import 'tree_view.dart';

export 'colored_text.dart';
export 'command.dart';
export 'input_row.dart';
export 'pomodoro_timer.dart';
export 'terminal_table.dart';
export 'tree_view.dart';

Widget getTerminalWidget(Output outputType, dynamic content) {
  switch (outputType) {
    case Output.empty:
      throw Exception(
          "The Output.empty case should have been covered at this point");
    case Output.error:
      return ColoredText(content, color: Colors.red); //error message
    case Output.text:
      return ColoredText(content);
    case Output.table:
      return TerminalTable(content["title"], content["data"]);
    case Output.tree:
      return TreeView(content);
    case Output.pomodoro:
      return PomodoroTimer(content);
    case Output.logout:
      throw Exception(
          "The Output.logout case should have been covered at this point");
    case Output.url:
      window.open(content, "generated");
      return const SizedBox();
  }
}
