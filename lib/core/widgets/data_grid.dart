import 'package:flutter/material.dart';

/// Lightweight enterprise-style data grid built on top of [DataTable].
/// Supports sorting, multi-select, and bulk actions through the controller.
class DataGridController {
  final void Function(List<int> selectedRows)? onSelectionChanged;
  DataGridController({this.onSelectionChanged});
}

class DataGridColumn {
  final String label;
  final bool numeric;
  final String key;

  DataGridColumn({required this.label, required this.key, this.numeric = false});
}

class DataGridRow {
  final Map<String, dynamic> cells;
  DataGridRow(this.cells);
}

class DataGrid extends StatefulWidget {
  final List<DataGridColumn> columns;
  final List<DataGridRow> rows;
  final DataGridController? controller;
  final bool selectable;

  const DataGrid({super.key, required this.columns, required this.rows, this.controller, this.selectable = true});

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final Set<int> _selected = {};

  void _onSelectChanged(bool? value, int index) {
    setState(() {
      if (value == true) _selected.add(index); else _selected.remove(index);
    });
    widget.controller?.onSelectionChanged?.call(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor: MaterialStateProperty.all(Colors.white10),
          dataRowColor: MaterialStateProperty.resolveWith((states) => Colors.white.withOpacity(0.02)),
          columns: [
            if (widget.selectable) DataColumn(label: const SizedBox(width: 12)),
            ...widget.columns.asMap().entries.map(
              (e) => DataColumn(
                label: Text(e.value.label),
                numeric: e.value.numeric,
                onSort: (ci, asc) {
                  setState(() {
                    _sortColumnIndex = ci;
                    _sortAscending = asc;
                    widget.rows.sort((a, b) {
                      final ak = a.cells[e.value.key];
                      final bk = b.cells[e.value.key];
                      if (ak is num && bk is num) return asc ? ak.compareTo(bk) : bk.compareTo(ak);
                      return asc ? '$ak'.compareTo('$bk') : '$bk'.compareTo('$ak');
                    });
                  });
                },
              ),
            ),
          ],
          rows: widget.rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return DataRow(
              selected: _selected.contains(index),
              onSelectChanged: widget.selectable ? (v) => _onSelectChanged(v, index) : null,
              cells: [
                if (widget.selectable) DataCell(const SizedBox(width: 12)),
                ...widget.columns.map((c) => DataCell(Text('${row.cells[c.key] ?? ''}'))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
