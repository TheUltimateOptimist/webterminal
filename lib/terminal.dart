import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// ignore: depend_on_referenced_packages
import 'package:statewithease/statewithease.dart';
import 'package:webterminal/helper_widgets/custom_icon_button.dart';
import 'package:webterminal/terminal_widgets/colored_text.dart';
import 'output.dart';
import 'terminal_theme.dart';
import 'terminal_widgets/widgets.dart' show getTerminalWidget, InputRow, Command;
import 'package:firebase_auth/firebase_auth.dart';

class TerminalState {
  TerminalState(this.contents, this.channel, this.user);

  final List<Widget> contents;
  WebSocketChannel? channel;
  StreamSubscription? channelSubscription;
  final User? user;

  factory TerminalState.initial() {
    final user = FirebaseAuth.instance.currentUser;
    return TerminalState(
      [user != null ? const CommandInputRow() : const EmailInputRow()],
      null,
      user,
    );
  }
}

TerminalState commandEntered(TerminalState old, String command) {
  old.contents.removeLast();
  old.contents.add(Command(text: command.trim()));
  old.channel!.sink.add(command.trim());
  return TerminalState(old.contents, old.channel, old.user);
}

TerminalState emailEntered(TerminalState old, String email) {
  old.contents.removeLast();
  old.contents.add(ColoredText("E-Mail: $email"));
  old.contents.add(PasswordInputRow(email));
  return TerminalState(old.contents, old.channel, old.user);
}

Future<TerminalState> passwordEntered(TerminalState old, String email, String password) async {
  old.contents.removeLast();
  old.contents.add(ColoredText("Password: ${'•' * password.length}"));
  try {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    old.contents.add(const CommandInputRow());
    return TerminalState(old.contents, old.channel, userCredential.user);
  } on FirebaseAuthException catch (error) {
    old.contents.add(ColoredText(error.code, color: Colors.red));
    old.contents.add(const EmailInputRow());
    return TerminalState(old.contents, old.channel, old.user);
  }
}

Future<StateStream<TerminalState>> connectToSocket(TerminalState old) async {
  final idToken = await old.user!.getIdToken();
  final channel = WebSocketChannel.connect(Uri.parse("ws://localhost:3000/terminal/$idToken"));
  return StateStream<TerminalState>(
    stream: channel.stream.map(
      (response) => (state) {
          final map = jsonDecode(response) as Map<String, dynamic>;
          final outputType = Output.fromString(map["code"]);
        if(outputType == Output.logout){
          FirebaseAuth.instance.signOut();
          state.contents.add(const EmailInputRow());
          return TerminalState(state.contents, state.channel, null);
        }
        else{
          state.contents.add(getTerminalWidget(outputType, map["content"]));
          state.contents.add(const CommandInputRow());
          return TerminalState(state.contents, state.channel, state.user);

        }
      },
    ),
    assign: (state, subscription) {
      state.channelSubscription = subscription;
      state.channel = channel;
    },
  );
}

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TerminalTheme.of(context).backgroundColor,
      child: StateProvider<TerminalState>(
        TerminalState.initial(),
        postFirstBuild: (context, state) {
          if(state.user != null){
            context.collectFutureStateStream(connectToSocket);
          } 
        },
        child: StateListener<TerminalState>(
          listenWhen: (previous, current) => previous.user == null && current.user != null,
          listener: (context, state) {
            context.collectFutureStateStream(connectToSocket);
          },
          child: StateBuilder<TerminalState>(
            builder: (p0, state) {
              return ListView.builder(
                itemCount: state.contents.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(
                      top: TerminalTheme.of(context).lineSpacing,
                      left: TerminalTheme.of(context).leftSpacing,
                    ),
                    child: state.contents[index],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class CommandInputRow extends StatelessWidget {
  const CommandInputRow({super.key});

  @override
  Widget build(BuildContext context) {
    return InputRow(
      prefix: const Command(),
      maxLines: null,
      onEnterPressed: (context, text) {
        context.collectOne(commandEntered, text);
      },
    );
  }
}

class EmailInputRow extends StatefulWidget {
  const EmailInputRow({super.key});

  @override
  State<EmailInputRow> createState() => _EmailInputRowState();
}

class _EmailInputRowState extends State<EmailInputRow> {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return InputRow(
      prefix: const ColoredText("E-Mail: "),
      onEnterPressed: (context, text) {
        context.collectOne(emailEntered, text);
      },
    );
  }
}

class PasswordInputRow extends StatefulWidget {
  const PasswordInputRow(this.email, {super.key});

  final String email;

  @override
  State<PasswordInputRow> createState() => _PasswordInputRowState();
}

class _PasswordInputRowState extends State<PasswordInputRow> {
  bool _isVisible = true;
  @override
  Widget build(BuildContext context) {
    return InputRow(
      isVisible: _isVisible,
      prefix: Row(
        children: [
          const ColoredText("Password: "),
          CustomIconButton(
            _isVisible ? Icons.visibility : Icons.visibility_off,
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
          ),
          const ColoredText(" "),
        ],
      ),
      onEnterPressed: (context, text) {
        context.collectFutureTwo(passwordEntered, widget.email, text);
      },
    );
  }
}
