import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final Color color;

  Profile(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Text('this is the profile screen'),
    );
  }
}
