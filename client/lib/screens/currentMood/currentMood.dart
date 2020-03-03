import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './newMood.dart';

class CurrentMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Your mood of the day.'),
      ),
      child: Center(
        child: AddMood(),
      ),
    );
  }
}

class AddMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 88, // estimated height of top title bar
          ),
          MoodDisplay(),
          AddMoodButton(),
        ]);
  }
}

// TODO make this take in data about user's moods for current day and display somehow
class MoodDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          width: 300.0,
          height: 300.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 15.0, // soften the shadow
                spreadRadius: 2.5, //extend the shadow
                offset: Offset(
                  10.0, // Move to right 10  horizontally
                  10.0, // Move to bottom 10 Vertically
                ),
              )
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue,
                Colors.purple,
                Colors.orange,
              ],
              stops: [0.2, 0.4, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class AddMoodButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      padding: const EdgeInsets.fromLTRB(50, 50, 50,
          100), // made it 100 from bottom assuming bottom nav is 50 pixels
      child: Center(
        child: CupertinoButton(
          minSize: 65,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(35.0),
          onPressed: () {
            // Add your onPressed code here!
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => NewMood(),
            ));
          },
          color: Colors.blue,
          child: Icon(
            Icons.add,
            size: 40.0,
          ),
        ),
      ),
    );
  }
}
