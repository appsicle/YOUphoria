import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login.dart';
import 'package:client/http.dart';
import '../currentMood/currentMood.dart';

class Profile extends StatefulWidget {
  final String username;
  final String token;

  Profile({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState(username, token);
}

class _ProfileState extends State<Profile> {
  String _token;
  String _username;
  String _gender = "";
  String _age = "";
  String _birthDate = "";
  String _zipcode = "";
  var _preferences = [];

  _ProfileState(this._username, this._token);

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  void getProfile() async {
    var response = await getData('profile/getProfile', this._token);
    if (response.statusCode != 200) {
      print('failed to get user profile.');
      return;
    }
    var body = decodeBody(response.body);
    setState(() {
      this._gender = body['gender'] == "" ? "N/A" : body['gender'];
      this._age = body['age'] == "" ? "N/A" : body['age'];
      this._birthDate = body['birthDate'] == "" ? "N/A" : body['birthDate'];
      this._zipcode = body['zipcode'] == "" ? "N/A" : body['zipcode'];
      this._preferences = body['preferences'];
      this._preferences.sort((a, b) {
        // sort the prefered activities/interests based on weights
        int c = int.parse(a["weight"]);
        int d = int.parse(b["weight"]);
        return (c < d) ? 1 : 0;
      });
    });
  }

  Chip interestChip(interest, color) {
    return Chip(
      elevation: 5,
      label: new Text(
        interest,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30, // space out for top part of screen
            ),
            MoodDisplay(
              token: this._token,
              circleSize: 140.0,
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  this._username,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: new BoxDecoration(
                border: new Border(
                  bottom: new BorderSide(
                    color: Colors.grey[300],
                    width: 2.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildStatItem("Gender", this._gender),
                  _buildStatItem("Birthday", this._birthDate),
                  _buildStatItem("Age", this._age),
                  _buildStatItem("Zipcode", this._zipcode),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Wrap(
                spacing: 5.0,
                children: List.generate(this._preferences.length, (index) {
                  List<Color> colors = [
                    Colors.greenAccent[400],
                    Colors.cyan,
                    Colors.indigoAccent,
                    Colors.deepPurple
                  ];
                  return interestChip(
                      this._preferences[index]['tag'], colors[index % 4]);
                }),
              ),
            ),
            Container(
              child: Center(
                child: RaisedButton(
                  color: Colors.indigoAccent,
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    // logout so remove this cached data
                    prefs.remove('username');
                    prefs.remove('token');

                    var response = await getData('profile/logout', this._token);
                    if (response.statusCode != 200) {
                      print("Logout failed.");
                    }

                    Navigator.of(context, rootNavigator: true).pushReplacement(
                        MaterialPageRoute(
                            builder: (BuildContext ctx) => new Login()));
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Container(height: 80), // cover the bottom part of screen
          ],
        ),
      ),
    );
  }
}
