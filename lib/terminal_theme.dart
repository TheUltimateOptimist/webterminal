import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminalThemeData {
  static TextStyle defaultStyle = GoogleFonts.ubuntuMono(fontSize: 20, color: Colors.white);
  TerminalThemeData(
      {Color? backgroundColor,
      TextStyle? lineStartStyle,
      TextStyle? inputStyle,
      EdgeInsets? space,
      this.lineSpacing = 5,
      this.leftSpacing = 5,
      this.tableTitleSpacing = 8,
      this.tableEntrySpacing = 10})
      : assert(lineStartStyle?.fontSize == inputStyle?.fontSize),
        assert(lineStartStyle?.height == inputStyle?.height),
        backgroundColor = backgroundColor ?? Colors.black,
        lineStartStyle = TerminalThemeData.defaultStyle,
        inputStyle = TerminalThemeData.defaultStyle;
  final Color backgroundColor;
  final TextStyle lineStartStyle;
  final TextStyle inputStyle;
  final double lineSpacing;
  final double leftSpacing;
  final double tableTitleSpacing;
  final double tableEntrySpacing;
}

class TerminalTheme extends InheritedWidget {
  TerminalTheme({super.key, required super.child, TerminalThemeData? data}) : data = data ?? TerminalThemeData();

  final TerminalThemeData data;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static TerminalThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<TerminalTheme>();
    assert(theme != null, "No TerminalTheme Inherited Widget could be found above in the widget tree.");
    return theme!.data;
  }
}
