import 'dart:async';

import 'package:flutter/material.dart';

import '../helper_widgets/custom_icon_button.dart';
import '../terminal_theme.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer(this.config, {super.key});

  final Map<String, dynamic> config;

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  late final Timer timer;
  late int remainingSeconds;
  bool isPause = false;
  bool isStopped = false;
  bool isCanceled = false;

  @override
  void initState() {
    remainingSeconds = widget.config["duration"];
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isStopped) return;
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      }
      if (remainingSeconds == 0 && isPause) {
        timer.cancel();
      }
      if (remainingSeconds == 0 && !isPause) {
        setState(() {
          isPause = true;
          remainingSeconds = widget.config["pause"];
        });
      }
    });
    super.initState();
  }

  String formatSeconds(int seconds) {
    int minutes = seconds ~/ 60; // get the whole number of minutes
    int remainingSeconds = seconds % 60; // get the remaining seconds
    String formattedMinutes = minutes < 10 ? '0$minutes' : '$minutes'; // add a leading zero if necessary
    String formattedSeconds = remainingSeconds < 10 ? '0$remainingSeconds' : '$remainingSeconds'; // add a leading zero if necessary
    return '$formattedMinutes:$formattedSeconds'; // return the formatted time string
  }

  @override
  Widget build(BuildContext context) {
    final style = TerminalTheme.of(context).inputStyle;
    final spacer = SizedBox(width: style.fontSize! / 2);
    if (isCanceled && !isPause) {
      return Text(
        "${widget.config['topic_name']} session was canceled",
        style: TerminalTheme.of(context).inputStyle,
      );
    }
    if ((remainingSeconds == 0 || isCanceled) && isPause) {
      return Text(
        widget.config["topic_name"],
        style: style.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }
    return Row(
      children: [
        Text(isPause ? "Pause" : widget.config['topic_name'], style: style),
        spacer,
        Text(
          formatSeconds(remainingSeconds),
          style: style.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),if(!isPause)
        spacer,
        if(!isPause)
        CustomIconButton(
          isStopped ? Icons.play_arrow_rounded : Icons.pause,
          onPressed: () {
            setState(() {
              isStopped = !isStopped;
            });
          },
        ),
        spacer,
        CustomIconButton(
          Icons.stop,
          onPressed: () {
            timer.cancel();
            setState(() {
              isCanceled = true;
            });
          },
        )
      ],
    );
  }
}