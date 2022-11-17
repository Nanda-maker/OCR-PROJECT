import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ocr_project/main.dart';
import 'package:ocr_project/pages/ListPage.dart';
import 'package:ocr_project/pages/sortable_page.dart';

class BottomNavBar extends StatefulWidget {
  final int initialState;
  const BottomNavBar(this.initialState);
  @override
  _BottomNavBar createState() => _BottomNavBar();
}

class _BottomNavBar extends State<BottomNavBar> {
  final initialState = 0;
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: widget.initialState,
      backgroundColor: Color(0xDB4BE8CC),
      items: <Widget>[
        Icon(Icons.list, size: 30),
        Icon(Icons.add, size: 30),
        Icon(Icons.person, size: 30),
        Icon(Icons.logout, size: 30),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SortablePage()),
          );
        }
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
      },
    );
  }
}
