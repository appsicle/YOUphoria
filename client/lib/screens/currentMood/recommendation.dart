import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// TODO format recommendation text
class Recommendation extends StatelessWidget {
  String _recommendation;

  Recommendation(this._recommendation);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Get Happy Recommendation'),
      ),
      child: Center(
        child: Text(_recommendation),
      ),
      backgroundColor: CupertinoColors.lightBackgroundGray,
    );
  }
}
