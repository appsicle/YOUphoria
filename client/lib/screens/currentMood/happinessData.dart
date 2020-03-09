import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../home/home.dart';

class HappinessData extends StatelessWidget {
  final String username;

  HappinessData({Key key, @required this.username}) : super(key: key);

  static final List<String> possibleActivities = [
    "Exercising",
    "Partying",
    "Playing Sports",
    "Playing Video Games",
    "Cooking",
    "Watching Movies",
    "Shopping",
    "Spending Time with Family",
    "Hiking",
    "Working"
  ];

  static List<String> getPossibleActivities() {
    return possibleActivities;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: EnterMoodData(username),
    );
  }
}

class EnterMoodData extends StatefulWidget {
  final String _username;

  EnterMoodData(this._username);

  @override
  _EnterMoodDataState createState() => _EnterMoodDataState(this._username);
}

class _EnterMoodDataState extends State<EnterMoodData> {
  List<String> _selectedActivities = [];
  final List<String> _possibleActivities =
      HappinessData.getPossibleActivities();
  final String _username;

  _EnterMoodDataState(this._username);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Why were you happy?'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 9,
            child: Container(
              padding: EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(10, (index) {
                  return Container(
                    height: 20,
                    width: 30,
                    child: ActivityButton(_possibleActivities[index], () {
                      setState(() {
                        String act = _possibleActivities[index];
                        if (_selectedActivities.contains(act)) {
                          _selectedActivities.remove(act);
                        } else {
                          _selectedActivities.add(act);
                        }
                        print(_selectedActivities);
                      });
                    }),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              // color: Colors.blueGrey,
              alignment: Alignment.topCenter,
              child: CupertinoButton(
                color: Colors.blueGrey,
                disabledColor: Colors.grey[300],
                onPressed: _selectedActivities.length > 0
                    ? () {
                        // TODO: send mood data to backend with selected activites
                        // Navigator.of(context)
                        //     .popUntil((route) => route.isFirst);
                        Navigator.of(context, rootNavigator: true)
                            .pushReplacement(MaterialPageRoute(
                                builder: (BuildContext ctx) =>
                                    new Home(username: _username)));
                        // should never not be 0 because we disable the button but just in case i guess
                        if (_selectedActivities.length > 0) {
                          print(_selectedActivities);
                        }
                      }
                    : null,
                child: Text('Confirm Selection'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ActivityButton extends StatefulWidget {
  final String name;
  final Function onPressed;

  const ActivityButton(this.name, this.onPressed);

  @override
  _ActivityButtonState createState() => _ActivityButtonState();
}

class _ActivityButtonState extends State<ActivityButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(10.0),
      borderRadius: BorderRadius.circular(15.0),
      color: this._isSelected ? Colors.greenAccent : Colors.grey[50],
      onPressed: () {
        widget.onPressed();
        setState(() {
          this._isSelected = !this._isSelected;
        });
      },
      child: Center(
        child: Text(
          widget.name,
          style: TextStyle(color: Colors.black, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
