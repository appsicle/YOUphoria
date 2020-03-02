import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          TitleSection(),
          MoodDisplay(),
          AddMoodButton(),
        ]);
  }
}

class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 80, 0, 30),
      child: Center(child: Text('Your mood of the day.')),
    );
  }
}

class MoodDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          padding: const EdgeInsets.fromLTRB(0, 80, 0, 30),
          child: Center(child: Text('temp space for circle with moods')),
          color: Colors.redAccent),
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
