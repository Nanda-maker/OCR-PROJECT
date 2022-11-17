
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocr_project/TransactionDetail.dart';
import 'package:ocr_project/model/transaction.dart';

class TransactionDetails extends StatefulWidget {
 final Transaction transaction;

  const TransactionDetails( this.transaction);


@override
_TransactionDetails createState() => _TransactionDetails();

}

class _TransactionDetails extends State<TransactionDetails>{
  bool shadowColor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Zap'),
        shadowColor:
        shadowColor ? Theme.of(context).colorScheme.shadow : null,
        backgroundColor: Color(0xDB4BE8CC)
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Text('Bank Name:'),
            title:Text(widget.transaction.bank),
          ),
          ListTile(
            leading: Text('Refrence No.:'),
            title:Text(widget.transaction.refrenceNumber),
          ),

          ListTile(
            leading: (widget.transaction.rrno != '') ? Text('RRNO:'):null,
            title:Text(widget.transaction.rrno),
          ),
          ListTile(
            leading: Text('Amount(Nu):'),
            title:Text(widget.transaction.amount.toString()),
          ),
          ListTile(
            leading: Text('From A/C:'),
            title:Text(widget.transaction.fromAC),
          ),
          ListTile(
            leading: Text('To A/C:'),
            title:Text(widget.transaction.toAC),
          ),
          ListTile(
            leading: Text('Date:'),
            title:Text(widget.transaction.date),
          ),
          ListTile(
            leading: Text('Time:'),
            title:Text(widget.transaction.time),
          ),
          ListTile(
            leading: Text('Remark:'),
            title:Text(widget.transaction.remark),
          ),
        ],
      ),
    );
  }
  }
