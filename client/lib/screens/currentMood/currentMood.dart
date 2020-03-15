import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './newMood.dart';
import 'package:intl/intl.dart';
import 'package:client/main.dart';
import 'package:http/http.dart';
import 'dart:convert';

class CurrentMood extends StatelessWidget {
  final String username;
  final String token;

  CurrentMood({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // navigationBar: CupertinoNavigationBar(
      //   middle: Text('Your mood of the day.'),
      // ),
      body: Center(
        child: AddMood(username: username, token: token),
      ),
    );
  }
}

class AddMood extends StatelessWidget {
  final String username;
  final String token;

  AddMood({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 88, // estimated height of top title bar
          ),
          MoodDisplay(token: token),
          AddMoodButton(username: username, token: token),
        ]);
  }
}

class MoodDisplay extends StatefulWidget {
  final String token;

  MoodDisplay({Key key, @required this.token}) : super(key: key);

  @override
  _MoodDisplayState createState() => _MoodDisplayState(this.token);
}

class _MoodDisplayState extends State<MoodDisplay> {
  List<String> _todaysMoods = [];
  String token;

  _MoodDisplayState(token) {
    this.token = token;
    setDailyMoods();
  }

  void setDailyMoods() async {
    var now = new DateTime.now();
    var formattedDate = new DateFormat("yyyy-MM-dd").format(now);
    var dateInformation = {"date": formattedDate};
    Response response =
        await postData("profile/login", dateInformation, this.token);
    var body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (body["calendar"].length > 0) {
        setState(() {
          _todaysMoods = body["calendar"].map((e) => e["mood"]).toList();
        });
      }
    }
  }

  final Map<String, Color> moodsToColor = {
    "amazing": Colors.greenAccent[400],
    "happy": Colors.greenAccent,
    "okay": Colors.cyan,
    "sad": Colors.indigoAccent,
    "horrible": Colors.deepPurpleAccent,
  };

  List<Color> generateColorsList(todaysMoods) {
    // sort function for ordering moods
    todaysMoods.sort((a, b) {
      if (a == "amazing") {
        return 0;
      } else if (a == "happy") {
        return b != "amazing" ? 0 : 1;
      } else if (a == "okay") {
        return (b != "amazing" && b != "happy") ? 0 : 1;
      } else if (a == "sad") {
        return b == "horrible" ? 0 : 1;
      } else {
        return 1;
      }
    });

    List<Color> result = [];
    for (int i = 0; i < todaysMoods.length; i++) {
      result.add(moodsToColor[todaysMoods[i]]);
    }
    return result;
  }

  List<double> generateStops(List<Color> todaysColors) {
    List<double> result = [];
    int numStops = todaysColors.length;
    double increment = 0.8 / numStops;
    double weight = increment;
    for (double i = 0; i < numStops; i++) {
      result.add(weight);
      weight += increment;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    setDailyMoods();
    List<Color> todaysColors;
    List<double> todaysStops;

    if (_todaysMoods.length == 0) {
      // case: no mood data entered for the day yet
      todaysColors = [
        Colors.grey,
        Colors.grey[300],
      ];
    } else {
      todaysColors = generateColorsList(_todaysMoods);
    }
    todaysStops = generateStops(todaysColors);

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
              colors: todaysColors,
              stops: todaysStops,
            ),
          ),
          child: Material(
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            shape: CircleBorder(),
            child: Ink(
              child: InkWell(
                // highlightColor: Colors.yellow[50],
                splashColor: Colors.black12,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddMoodButton extends StatelessWidget {
  final String username;
  final String token;

  AddMoodButton({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(50, 50, 50,
          100), // made it 100 from bottom assuming bottom nav is 50 pixels
      child: Center(
        child: CupertinoButton(
          minSize: 65,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(35.0),
          onPressed: () {
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => NewMood(username: username, token: token),
            ));
          },
          color: Colors.indigoAccent,
          child: Icon(
            Icons.add,
            size: 40.0,
          ),
        ),
      ),
    );
  }
}
