import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
  final Color color;

  Calendar(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Text('this is the calendar screen'),
    );
  }
}
