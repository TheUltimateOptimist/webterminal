import 'package:flutter/material.dart';

import '../terminal_theme.dart';

class TreeRow {
  const TreeRow(this.name, this.depth);
  final String name;
  final int depth;

  @override
  String toString() {
    return "TreeRow($name, $depth)";
  }
}

class TreeView extends StatelessWidget {
  const TreeView(this.node, {super.key});

  final Map<String, dynamic> node;

  void addTreeRows(
      List<TreeRow> treeRows, Map<String, dynamic> node, int depth) {
    final nameNotNone = node["name"] != null;
    if (nameNotNone) {
      treeRows.add(TreeRow(node["name"], depth));
    }
    final children = node["children"];
    if (children != null) {
      if (nameNotNone) {
        depth += 1;
      }
      for (final child in children) {
        addTreeRows(treeRows, child, depth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final treeRows = List<TreeRow>.empty(growable: true);
    addTreeRows(treeRows, node, 0);
    final identation = 4 * (TerminalTheme.of(context).inputStyle.fontSize! / 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final treeRow in treeRows)
          Container(
            margin: EdgeInsets.only(
                top: TerminalTheme.of(context).lineSpacing,
                left: identation * treeRow.depth),
            child: Text(
              treeRow.name,
              style: TerminalTheme.of(context).inputStyle,
            ),
          )
      ],
    );
  }
}
