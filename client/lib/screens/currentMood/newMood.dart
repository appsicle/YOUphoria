import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './happinessData.dart';
import 'package:ndialog/ndialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:client/http.dart';
import '../home/home.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var _event = {};
  String _recommendationCategory = "";

  SliderState(this._username, this._token);

  @override
  void initState() {
    _updateCurrentLocation();
    super.initState();
  }

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
              String formattedTime = new DateFormat("HH:mm:ss").format(now);
              var moodInformation = {
                "mood": this._currentMood,
                "date": formattedDate,
                "time": formattedTime
              };
              await postData("mood/addMood", moodInformation, this._token);
              if (_moodValue >= _threshold) {
                _goToHappinessDataScreen();
              } else {
                var json = {
                  'username': this.widget._username,
                  'token': this._token,
                  'latitude': _currentPosition.latitude,
                  'longitude': _currentPosition.longitude
                };
                var response = await postData(
                    'recommendation/getRecommendation', json, this._token);
                var body = decodeBody(response.body);
                setState(() {
                  _event = body;
                  _recommendationCategory = _event['category'];
                });
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

  void _goToHappinessDataScreen() {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => HappinessData(username: _username, token: _token),
    ));
  }

  void _goToRecommendationPopup() async {
    await showDialog(
        context: context,
        builder: (context) {
          return NDialog(
            dialogStyle: DialogStyle(titleDivider: true),
            title: Container(
              padding: EdgeInsets.all(10.0),
              child: Text(_event['name']),
            ),
            content: FractionallySizedBox(
              heightFactor: .8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(children: [
                        Text(_event['description']),
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Image(
                            image: NetworkImage(_event['image_url']),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                                child: Text("Click here",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue)),
                                onTap: () async {
                                  await launch(_event['event_site_url']);
                                })),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('Category: ' + _event['category']),
                        )
                      ]),
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
                  onPressed: () async {
                    await _rateRecommendation("1");
                    Navigator.of(context).pop();
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
                  onPressed: () async {
                    await _rateRecommendation("0");
                    Navigator.of(context).pop();
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
                new Home(username: _username, token: _token)));
  }

  // rating should only be 0 (bad) or 1 (good), and be a String
  Future<void> _rateRecommendation(String rating) async {
    var feedbackInformation = {
      'tags': [_recommendationCategory],
      'liked': rating
    };
    var response = await postData(
        "recommendation/sendFeedback", feedbackInformation, _token);
    if (response.statusCode != 200) {
      print('failed to send feedback');
    }
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
