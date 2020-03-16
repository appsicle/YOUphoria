import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';
import '../currentMood/happinessData.dart';
import 'package:client/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInterests extends StatefulWidget {
  final String username;
  final String token;

  UserInterests({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  _UserInterestsState createState() => _UserInterestsState(username, token);
}

class _UserInterestsState extends State<UserInterests> {
  final String _username;
  final String _token;

  _UserInterestsState(this._username, this._token);

  List<String> _selectedActivities = [];
  final List<String> _possibleActivities =
      HappinessData.getPossibleActivities();

  @override
  void initState() {
    setCurrentStateOfScreen();
    super.initState();
  }

  void setCurrentStateOfScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userInterests", "true");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(top: 60.0, left: 20, right: 20),
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Select some of your interests/hobbbies!',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                children: List.generate(_possibleActivities.length, (index) {
                  return Container(
                    height: 20,
                    width: 30,
                    child: ActivityButton(_possibleActivities[index], () {
                      setState(() {
                        String act = HappinessData.getActivityKey(
                            _possibleActivities[index]);
                        if (_selectedActivities.contains(act)) {
                          _selectedActivities.remove(act);
                        } else {
                          _selectedActivities.add(act);
                        }
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
              alignment: Alignment.topCenter,
              child: CupertinoButton(
                color: Colors.blueGrey,
                disabledColor: Colors.grey[300],
                onPressed: _selectedActivities.length > 0
                    ? () async {
                        var response = await postData(
                            "recommendation/sendUserInterests",
                            {'interests': _selectedActivities},
                            _token);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        if (response.statusCode == 200) {
                          prefs.remove(
                              "userInterests"); // only remove this if they were able to addProfileDetails successfully
                          Navigator.of(context, rootNavigator: true)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (BuildContext ctx) => new Home(
                                      username: this._username,
                                      token: this._token)));
                        } else {
                          print('failed to send user interests.');
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
