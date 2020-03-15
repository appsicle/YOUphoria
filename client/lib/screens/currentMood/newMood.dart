import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './happinessData.dart';
import 'package:ndialog/ndialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:client/http.dart';
import 'currentMood.dart';

class NewMood extends StatelessWidget {
  final String username;
  final String token;

  NewMood({Key key, @required this.username, @required this.token})
      : super(key: key);

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
              child: MoodSlider(username, token),
            ),
          ],
        ),
      ),
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
    );
  }
}

class MoodSlider extends StatefulWidget {
  final String _username;
  final String _token;

  MoodSlider(this._username, this._token);

  @override
  SliderState createState() => SliderState(_username, _token);
}

class SliderState extends State<MoodSlider> {
  double _threshold = 60;
  double _moodValue = 50;
  Color _moodColor = Colors.cyan;
  final String _username;
  final String _token;
  Position _currentPosition;
  String _currentMood =
      "okay"; // todo eventually will be used when sending data to backend

  SliderState(this._username, this._token);

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {
              _updateCurrentLocation(); // update current location
              var now = new DateTime.now();
              String formattedDate = new DateFormat("yyyy-MM-dd").format(now);
              String formattedTime = new DateFormat("H:m:s").format(now);
              var moodInformation = {
                "mood": this._currentMood,
                "date": formattedDate,
                "time": formattedTime
              };
              var response =
                  await postData("mood/addMood", moodInformation, this._token);
              print(response.statusCode);

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
      builder: (context) => HappinessData(username: _username, token: _token),
    ));
  }

  void _goToRecommendationPopup() async {
    // TODO send mood data to backend (API call)

    // TODO check if for some reason _currentPosition is null, handle that case
    // can use _currentPosition.latitude and currentPosition.longitude

    // TODO do another API call to get actual recommendation and send in location

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

    Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext ctx) =>
                new CurrentMood(username: _username, token: _token)));
  }

  // TODO send feedback on recommendation
  // rating should only be 0 (bad) or 1 (good)
  void rateRecommendation(int recommendationId, int rating) {
    print("recommendation with ID: " +
        recommendationId.toString() +
        " rated: " +
        rating.toString());
  }

  void _updateCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
      // Navigator.of(context).pop();
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
