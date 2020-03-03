import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HappinessData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Enter Your Happiness Data'),
      ),
      child: Center(
        child: Text("temp"),
      ),
      backgroundColor: CupertinoColors.lightBackgroundGray,
    );
  }
}
