import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// ignore: depend_on_referenced_packages
import 'package:statewithease/statewithease.dart';
import 'terminal_theme.dart';
import 'terminal_widgets/widgets.dart' show getTerminalWidget, InputRow, Command;

class TerminalState {
  const TerminalState(this.contents, this.channel);

  final List<Widget> contents;
  final WebSocketChannel channel;
}

TerminalState commandEntered(TerminalState old, String command) {
  old.contents.add(Command(text: command.trim()));
  old.channel.sink.add(command.trim());
  return TerminalState(old.contents, old.channel);
}

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    final channel = WebSocketChannel.connect(Uri.parse("ws://localhost:3000/terminal"));
    return Container(
      color: TerminalTheme.of(context).backgroundColor,
      child: StateProvider<TerminalState>(
        TerminalState(List.empty(growable: true), channel),
        mapperStream: channel.stream.map((event) => (state) {
              state.contents.add(getTerminalWidget(event));
              return TerminalState(state.contents, channel);
            }),
        child: StateBuilder<TerminalState>(
          builder: (p0, state) {
            return ListView.builder(
              itemCount: state.contents.length + 1,
              itemBuilder: (context, index) {
                final Widget widget;
                if (state.contents.isEmpty) {
                  widget = const InputRow();
                } else if (index == state.contents.length && state.contents.last is! Command) {
                  widget = const InputRow();
                } else if (index == state.contents.length && state.contents.last is Command) {
                  widget = const SizedBox();
                } else {
                  widget = state.contents[index];
                }
                return Container(
                  margin: EdgeInsets.only(
                    top: TerminalTheme.of(context).lineSpacing,
                    left: TerminalTheme.of(context).leftSpacing,
                  ),
                  child: widget,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
