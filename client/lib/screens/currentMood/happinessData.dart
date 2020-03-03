import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// TODO make this screen be a place for users to add additional information on why they are in a good mood
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
