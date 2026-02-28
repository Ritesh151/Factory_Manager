import 'package:flutter/material.dart';

/// Desktop-optimized data table with fixed header and scroll.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.onRowTap,
  });
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;
  final void Function(int index)? onRowTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 48,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          columns: columns,
          rows: [
            for (var i = 0; i < rows.length; i++)
              DataRow(
                cells: rows[i].cells,
                onSelectChanged: onRowTap != null
                    ? (_) => onRowTap!(i)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
