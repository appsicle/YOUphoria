import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../home/home.dart';
import 'package:client/http.dart';

class HappinessData extends StatelessWidget {
  final String username;
  final String token;

  HappinessData({Key key, @required this.username, @required this.token})
      : super(key: key);

  static final Map<String, String> possibleActivities = {
    "Music": "music",
    "Visual Arts": "visual-arts",
    "Performing Arts": "performing-arts",
    "Film": "film",
    "Lectures & Books": "lectures-books",
    "Fashion": "fashion",
    "Food & Drink": "food-and-drink",
    "Festivals & Fairs": "festivals-fairs",
    "Charities": "charities",
    "Sports & Active Life": "sports-active-life",
    "Nightlife": "nightlife",
    "Kids & Family": "kids-family"
  };

  static List<String> getPossibleActivities() {
    return possibleActivities.keys.toList();
  }

  static String getActivityKey(String activity) {
    return possibleActivities[activity];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: EnterMoodData(username, token),
    );
  }
}

class EnterMoodData extends StatefulWidget {
  final String _username;
  final String _token;

  EnterMoodData(this._username, this._token);

  @override
  _EnterMoodDataState createState() =>
      _EnterMoodDataState(this._username, this._token);
}

class _EnterMoodDataState extends State<EnterMoodData> {
  List<String> selectedActivities = [];
  final List<String> _possibleActivities =
      HappinessData.getPossibleActivities();
  final String _username;
  final String _token;

  _EnterMoodDataState(this._username, this._token);

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
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(_possibleActivities.length, (index) {
                  return Container(
                    height: 20,
                    width: 30,
                    child: ActivityButton(_possibleActivities[index], () {
                      if (mounted) {
                        setState(() {
                          String act = HappinessData.getActivityKey(
                              _possibleActivities[index]);
                          if (selectedActivities.contains(act)) {
                            selectedActivities.remove(act);
                          } else {
                            selectedActivities.add(act);
                          }
                        });
                      }
                    }),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.topCenter,
              child: CupertinoButton(
                color: Colors.blueGrey,
                disabledColor: Colors.grey[300],
                onPressed: selectedActivities.length > 0
                    ? () async {
                        var response = await postData(
                            "recommendation/sendFeedback",
                            {'tags': selectedActivities, 'liked': "1"},
                            _token);
                        if (response.statusCode != 200) {
                          print('failed to send feedback');
                        }
                        Navigator.of(context, rootNavigator: true)
                            .pushReplacement(MaterialPageRoute(
                                builder: (BuildContext ctx) => new Home(
                                    username: _username, token: _token)));
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
        if (mounted) {
          setState(() {
            this._isSelected = !this._isSelected;
          });
        }
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
