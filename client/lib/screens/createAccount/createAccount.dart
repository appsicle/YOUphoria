import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';
import '../currentMood/happinessData.dart';
import 'package:client/http.dart';

class CreateAccount extends StatefulWidget {
  final String username;
  final String token;

  CreateAccount({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState(username, token);
}

class _CreateAccountState extends State<CreateAccount> {
  final String _username;
  final String _token;

  _CreateAccountState(this._username, this._token);

  List<String> _selectedActivities = [];
  final List<String> _possibleActivities =
      HappinessData.getPossibleActivities();

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
              padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 25.0),
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
                        if (response.statusCode != 200) {
                          print('failed to send user interests.');
                        }

                        Navigator.of(context, rootNavigator: true)
                            .pushReplacement(MaterialPageRoute(
                                builder: (BuildContext ctx) => new Home(
                                    username: this._username,
                                    token: this._token)));
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
