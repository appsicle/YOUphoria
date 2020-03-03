import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './currentMood.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Center(
                child: Text(_recommendation),
              ),
            ),
            CupertinoButton(
              minSize: 65,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(35.0),
              onPressed: () {
                // TODO make this transition less ugly
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              color: Colors.blue,
              child: Icon(
                Icons.add,
                size: 40.0,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: CupertinoColors.lightBackgroundGray,
    );
  }
}
