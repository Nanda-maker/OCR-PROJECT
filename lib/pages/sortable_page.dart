import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ocr_project/data/transactions.dart';
import 'package:ocr_project/model/transaction.dart';
import 'package:ocr_project/widget/scrollable_widget.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widget/bottom_bar.dart';

class SortablePage extends StatefulWidget {
  @override
  _SortablePageState createState() => _SortablePageState();
}

class _SortablePageState extends State<SortablePage> {
  late List<Transaction> transacions;
  int? sortColumnIndex;
  bool isAscending = false;
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  void initState() {
    super.initState();

    this.transacions = List.of(allTransactions);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title:  Text('Zap'),
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor:
      shadowColor ? Theme.of(context).colorScheme.shadow : null,
      backgroundColor: Color(0xDB4BE8CC),
      automaticallyImplyLeading: false,
    ),
        bottomNavigationBar: BottomNavBar(0),
        body: ScrollableWidget(child: buildDataTable()),
      );

  Widget buildDataTable() {
    final columns = ['APP', 'Refrence No.', 'Amount(Nu)'];

    return DataTable(
      sortAscending: isAscending,
      sortColumnIndex: sortColumnIndex,
      columns: getColumns(columns),
      rows: getRows(transacions),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            label: Text(column),
            onSort: onSort,
          ))
      .toList();

  List<DataRow> getRows(List<Transaction> transacions) =>
      transacions.map((Transaction transaction) {
        final cells = [
          transaction.bank,
          transaction.refrenceNumber,
          transaction.amount
        ];

        return DataRow(cells: getCells(cells));
      }).toList();

  List<DataCell> getCells(List<dynamic> cells) =>
      cells.map((data) => DataCell(Text('$data'))).toList();

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      transacions.sort((transaction1, transaction2) =>
          compareString(ascending, transaction1.bank, transaction2.bank));
    } else if (columnIndex == 1) {
      transacions.sort((transaction1, transaction2) => compareString(
          ascending, transaction1.refrenceNumber, transaction2.refrenceNumber));
    } else if (columnIndex == 2) {
      transacions.sort((transaction1, transaction2) => compareString(
          ascending, '${transaction1.amount}', '${transaction1.amount}'));
    }

    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);
}
