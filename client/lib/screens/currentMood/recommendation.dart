import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Recommendation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Get Happy Recommendation'),
      ),
      child: Center(
        child: Text("temp"),
      ),
      backgroundColor: CupertinoColors.lightBackgroundGray,
    );
  }
}
