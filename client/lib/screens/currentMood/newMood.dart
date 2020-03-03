import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import './happinessData.dart';
import 'package:ndialog/ndialog.dart';

class NewMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Mood'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Moods(),
            ),
            Container(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FractionallySizedBox(
          widthFactor: .95,
          child: Container(
            alignment: Alignment.center,
            child: FlutterSlider(
              rtl: false,
              axis: Axis.horizontal,
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
          width: 200,
          padding: EdgeInsets.all(20.0),
          child: CupertinoButton(
            minSize: 60,
            padding: EdgeInsets.all(15.0),
            borderRadius: BorderRadius.circular(15.0),
            onPressed: () {
              // print(_moodValue);
              if (_moodValue >= _threshold) {
                goToHappinessDataScreen();
              } else {
                goToRecommendationPopup();
              }
            },
            color: Colors.cyan,
            child: Text("SUBMIT MOOD"),
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

  // TODO do API call to get actual recommendation
  void goToRecommendationPopup() async {
    String recommendation = "temporary recommendation";

    await showDialog(
        context: context,
        builder: (context) {
          return NDialog(
            dialogStyle: DialogStyle(titleDivider: true),
            title: Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                  "We see that you're not feeling too great, here's a recommendation!"),
            ),
            content: SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Container(
                child: Text(recommendation),
              ),
            ),
            actions: <Widget>[
              Container(),
              Container(
                padding: EdgeInsets.all(20.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(),
            ],
          );
        });

    Navigator.of(context).pop();
  }
}

class Moods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        child: Row(
          verticalDirection: VerticalDirection.down,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Icon(Icons.sentiment_very_dissatisfied, size: 60),
            Icon(Icons.sentiment_neutral, size: 60),
            Icon(Icons.sentiment_very_satisfied, size: 60),
          ],
        ),
      ),
    );
  }
}
