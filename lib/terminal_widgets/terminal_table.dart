import 'package:flutter/material.dart';

import '../terminal_theme.dart';

class ListEntry<T> {
  const ListEntry(this.index, this.value);
  final int index;
  final T value;
}

extension Enumerate<T> on List<T> {
  Iterable<ListEntry<T>> enumerate() {
    return Iterable.generate(length, (index) => ListEntry(index, this[index]));
  }
}

class TerminalTable extends StatelessWidget {
  const TerminalTable(this.title, this.data, {super.key});

  final String title;
  final List<dynamic> data;

  Map<int, TableColumnWidth> getColumnWidths(List<dynamic> data, BuildContext context) {
    Map<int, int> columnLengths = {};
    for (final row in data) {
      for (final text in (row as List).enumerate()) {
        final length = (text.value as String).length;
        if (columnLengths[text.index] == null || columnLengths[text.index]! < length) {
          columnLengths[text.index] = length;
        }
      }
    }
    final multiplier = TerminalTheme.of(context).inputStyle.fontSize! / 2;
    final additional = TerminalTheme.of(context).tableEntrySpacing * 2;
    return columnLengths.map((key, value) => MapEntry(key, FixedColumnWidth(value * multiplier + additional)));
  }

  @override
  Widget build(BuildContext context) {
    const light = BorderSide(color: Colors.white, width: 1);
    final columnWidths = getColumnWidths(data, context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(margin: EdgeInsets.only(bottom: TerminalTheme.of(context).tableTitleSpacing), child: Text(title, style: TerminalTheme.of(context).inputStyle)),
        Table(
          border: TableBorder.all(color: Colors.white, width: 3),
          columnWidths: columnWidths,
          children: [
            TableRow(
              children: [
                for (final child in data.first)
                  Container(
                    margin: EdgeInsets.all(TerminalTheme.of(context).tableEntrySpacing),
                    child: Text(
                      child,
                      style: TerminalTheme.of(context).inputStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            )
          ],
        ),
        Table(
          border: const TableBorder(top: BorderSide.none, left: light, right: light, bottom: light, horizontalInside: light, verticalInside: light),
          columnWidths: columnWidths,
          children: [
            for (final row in data.skip(1))
              TableRow(
                children: [
                  for (final child in row)
                    Container(
                      margin: EdgeInsets.all(TerminalTheme.of(context).tableEntrySpacing),
                      child: Text(
                        child,
                        style: TerminalTheme.of(context).inputStyle,
                      ),
                    ),
                ],
              )
          ],
        ),
      ],
    );
  }
}