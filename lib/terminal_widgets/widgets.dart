import 'dart:convert';

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

Widget getTerminalWidget(String response) {
  final map = jsonDecode(response) as Map<String, dynamic>;
  final outputType = Output.fromString(map["code"]);
  switch (outputType) {
    case Output.empty:
      return const SizedBox(); //empty
    case Output.error:
      return ColoredText(map["content"], color: Colors.red); //error message
    case Output.text:
      return ColoredText(map["content"]);
    case Output.table:
      return TerminalTable(map["content"]["title"], map["content"]["data"]);
    case Output.tree:
      return TreeView(map["content"]);
    case Output.pomodoro:
      return PomodoroTimer(map["content"]);
  }
}