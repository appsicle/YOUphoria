import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './happinessData.dart';
import 'package:ndialog/ndialog.dart';
import 'package:geolocator/geolocator.dart';

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
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
    );
  }
}

class MoodSlider extends StatefulWidget {
  @override
  SliderState createState() => SliderState();
}

class SliderState extends State<MoodSlider> {
  double _threshold = 60;
  double _moodValue = 50;
  Color _moodColor = Colors.cyan;
  Position _currentPosition;
  String _currentMood =
      "okay"; // todo eventually will be used when sending data to backend

  @override
  Widget build(BuildContext context) {
    _getCurrentLocation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FractionallySizedBox(
          widthFactor: .85,
          alignment: Alignment.center,
          child: CupertinoSlider(
            value: _moodValue,
            min: 1,
            max: 100,
            activeColor: _moodColor,
            onChanged: (value) {
              setState(() {
                _moodValue = value;
                _updateCurrentMood();
              });
            },
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
              _getCurrentLocation(); // update current location
              if (_moodValue >= _threshold) {
                _goToHappinessDataScreen();
              } else {
                _goToRecommendationPopup();
              }
            },
            color: _moodColor,
            child: Text("SUBMIT MOOD"),
          ),
        ),
      ],
    );
  }

  void _updateCurrentMood() {
    if (_moodValue < 20) {
      this._moodColor = Colors.deepPurpleAccent;
      this._currentMood = "horrible";
    } else if (_moodValue < 40) {
      this._moodColor = Colors.indigoAccent;
      this._currentMood = "sad";
    } else if (_moodValue < 60) {
      this._moodColor = Colors.cyan;
      this._currentMood = "okay";
    } else if (_moodValue < 80) {
      this._moodColor = Colors.greenAccent;
      this._currentMood = "happy";
    } else {
      this._moodColor = Colors.greenAccent[400];
      this._currentMood = "amazing";
    }
  }

  // TODO add anything additional we need to do before changing screens
  void _goToHappinessDataScreen() {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => HappinessData(),
    ));
  }

  // TODO do API call to get actual recommendation
  void _goToRecommendationPopup() async {
    print(
        _currentPosition); // can use currentPosition.latitude and currentPosition.longitude
    // TODO check if for some reason _currentPosition is null, handle that case
    int recommendationId = 123; // temp
    String recommendation =
        "temporary recommendation this text area is scrollable btw when it overflows"; // temp

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
            content: Container(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        child: Text(recommendation),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      "How was your recommendation?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    rateRecommendation(recommendationId, 1);
                  },
                  color: Colors.greenAccent[700],
                  child: Icon(
                    Icons.thumb_up,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    rateRecommendation(recommendationId, 0);
                  },
                  color: Colors.redAccent,
                  child: Icon(
                    Icons.thumb_down,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });

    Navigator.of(context).pop();
  }

  // TODO send feedback on recommendation
  // rating should only be 0 (bad) or 1 (good)
  void rateRecommendation(int recommendationId, int rating) {
    print("recommendation with ID: " +
        recommendationId.toString() +
        " rated: " +
        rating.toString());
  }

  void _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
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
            Icon(
              Icons.sentiment_very_dissatisfied,
              size: 60,
              color: Colors.black,
            ),
            Icon(
              Icons.sentiment_neutral,
              size: 60,
              color: Colors.black,
            ),
            Icon(
              Icons.sentiment_very_satisfied,
              size: 60,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
