import 'package:flutter/material.dart';

class CurrentMood extends StatelessWidget {
  final Color color;

  CurrentMood(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}
