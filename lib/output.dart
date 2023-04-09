enum Output {
  empty(200),
  error(201),
  text(202),
  table(203),
  tree(204),
  pomodoro(205),
  logout(206);

  final int code;
  const Output(this.code);

  factory Output.fromString(int code) {
    switch (code) {
      case 200:
        return Output.empty;
      case 201:
        return Output.error;
      case 202:
        return Output.text;
      case 203:
        return Output.table;
      case 204:
        return Output.tree;
      case 205:
        return Output.pomodoro;
      case 206:
        return Output.logout;
      default:
        throw Exception("invalid code");
    }
  }
}