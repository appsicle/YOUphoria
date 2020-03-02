import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './newMood.dart';

class CurrentMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AddMood(),
    );
  }
}

class AddMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Center(
        child: CupertinoButton(
            onPressed: () {
              // Add your onPressed code here!
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => NewMood(),
              ));
            },
            child: Text('Add Mood'),
            color: CupertinoColors.darkBackgroundGray),
      ),
    );
  }
}

