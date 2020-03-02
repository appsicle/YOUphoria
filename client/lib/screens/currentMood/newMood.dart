import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class NewMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Mood'),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Moods(),
            ),
            Expanded(
              child: Container(
                child: MoodSlider(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: CupertinoColors.lightBackgroundGray,
    );
  }
}

class MoodSlider extends StatefulWidget {
  @override
  SliderState createState() => SliderState();
}

class SliderState extends State<MoodSlider> {
  double _lowerValue = 50;
  double _upperValue = 180;
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .7,
      child: Container(
        alignment: Alignment.center,
        child: FlutterSlider(
          rtl: true,
          axis: Axis.vertical,
          values: [50],
          max: 100,
          min: 0,
          onDragging: (handlerIndex, lowerValue, upperValue) {
            _lowerValue = lowerValue;
            _upperValue = upperValue;
            // setState(() {});
          },
        ),
      ),
    );
  }
}

class Moods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: Column(
          verticalDirection: VerticalDirection.down,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Icon(Icons.sentiment_very_satisfied, size: 60),
            Icon(Icons.sentiment_neutral, size: 60),
            Icon(Icons.sentiment_very_dissatisfied, size: 60),
      
          ],
        ),
      ),
    );
  }
}

// TODO: keep track of state for slider and send to backend