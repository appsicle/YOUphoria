import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import './recommendation.dart';
import './happinessData.dart';

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
              child: MoodSlider(),
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
  double _threshold = 70;
  double _moodValue = 50;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FractionallySizedBox(
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
                setState(() {
                  _moodValue = lowerValue;
                });
              },
            ),
          ),
        ),
        Container(
          width: 125,
          padding: EdgeInsets.only(right: 20),
          child: CupertinoButton(
            minSize: 60,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(15.0),
            onPressed: () {
              print(_moodValue);
              if (_moodValue >= _threshold) {
                goToHappinessDataScreen();
              } else {
                goToRecommendationScreen();
              }
            },
            color: Colors.black54,
            child: Text("SUBMIT"),
          ),
        ),
      ],
    );
  }

  // TODO add anything additional we need to do before changing screens
  void goToHappinessDataScreen() {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => HappinessData(),
    ));
  }

  // TODO do API call to get actual recommendation to pass as String
  void goToRecommendationScreen() {
    String recommendation = "temporary recommendation";

    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => Recommendation(recommendation),
    ));
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
