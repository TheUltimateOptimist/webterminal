import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:statewithease/statewithease.dart';

void main() {
  runApp(const MyApp());
}

abstract class TerminalRow{
}

class TerminalCommand implements TerminalRow{
  const TerminalCommand(this.text);
  final String text;
}

class TerminalOutput implements TerminalRow{
  const TerminalOutput(this.text);
  final String text;
}

class TerminalWidget implements TerminalRow{
  const TerminalWidget(this.widget);
  final Widget widget;
}

class TerminalThemeData {
  static TextStyle defaultStyle = const TextStyle(fontSize: 16, color: Colors.white);
  TerminalThemeData({Color? backgroundColor, TextStyle? lineStartStyle, TextStyle? inputStyle, EdgeInsets? space})
      : assert(lineStartStyle?.fontSize == inputStyle?.fontSize),
        assert(lineStartStyle?.height == inputStyle?.height),
        backgroundColor = backgroundColor ?? Colors.black,
        lineStartStyle = TerminalThemeData.defaultStyle,
        inputStyle = TerminalThemeData.defaultStyle,
        space = const EdgeInsets.only(left: 5);
  final Color backgroundColor;
  final TextStyle lineStartStyle;
  final TextStyle inputStyle;
  final EdgeInsets space;
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

enum Keys {
  enter(0x10000000d);

  const Keys(this.id);
  final int id;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TerminalTheme(child: const Terminal()),
    );
  }
}

enum TerminalTextType{
  command, 
  output
}

class TerminalText{
  const TerminalText(this.text, this.type);
  final TerminalTextType type;
  final String text;
}

class TerminalState {
  const TerminalState(this.contents);

  final List<TerminalText> contents;
}

TerminalState commandEntered(TerminalState old, String command) {
  final terminalText = TerminalText(command.trim(), TerminalTextType.command);
  old.contents.add(terminalText);
  old.contents.add(const TerminalText("it worked", TerminalTextType.output));
  return TerminalState(old.contents);
}

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TerminalTheme.of(context).backgroundColor,
      child: StateProvider<TerminalState>(
        TerminalState(List.empty(growable: true)),
        child: StateBuilder<TerminalState>(
          builder: (p0, state) {
            final space = TerminalTheme.of(context).space;
            return Container(margin: EdgeInsets.only(top: space.top, bottom: space.bottom),
              child: ListView.builder(
                itemCount: state.contents.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.contents.length) {
                    return  const InputRow();
                  }
                  switch(state.contents[index].type){
                    case TerminalTextType.command:
                      return Command(text: state.contents[index].text);
                    case TerminalTextType.output:
                      return Output(state.contents[index].text);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

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
                if (value is KeyDownEvent && value.logicalKey.keyId == Keys.enter.id) {
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

class Command extends StatelessWidget {
  const Command({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: TerminalTheme.of(context).space,
      child: RichText(
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
      ),
    );
  }
}

class Output extends StatelessWidget {
  const Output(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(margin: TerminalTheme.of(context).space, child: Text(text, style: TerminalTheme.of(context).inputStyle,),);
  }
}
