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

class MoodDisplay extends StatelessWidget {
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
    // TODO get colors and stops based on user's moods of the day
    List<String> todaysMoods = ["sad", "happy", "amazing", "horrible", "okay"];

    List<Color> todaysColors = generateColorsList(todaysMoods);
    List<double> todaysStops = generateStops(todaysColors);
    // print(todaysColors);
    // print(todaysStops);

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
        ),
      ),
    );
  }
}

class AddMoodButton extends StatelessWidget {
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
              builder: (context) => NewMood(),
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
