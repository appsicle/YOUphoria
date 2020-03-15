import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login.dart';
import 'package:client/http.dart';
import 'dart:math';

// TODO finalize what is going to go on this screen and DO IT
class Profile extends StatefulWidget {
  final String username;
  final String token;

  Profile({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState(token);
}

class _ProfileState extends State<Profile> {
  String token;
  var preferences;

  _ProfileState(token) {
    this.token = token;
  }

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  void getProfile() async {
    var response = await getData('profile/getProfile', this.token);
    if (response.statusCode != 200) {
      this.preferences = [];
      print('failed to get user profile.');
      return;
    }
    setState(() {
      print(decodeBody(response.body));
      this.preferences = decodeBody(response.body)['preferences'];
      print(this.preferences);
    });
  }

  Container profileData(data) {
    return Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            color: Colors.grey[300],
            width: 3.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
      padding: EdgeInsets.all(25.0),
      child: Text(data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Profile'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  this.widget.username,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0.0),
                children:
                    List.generate(max(this.preferences.length, 20), (index) {
                  return profileData(this.preferences[1]['tag']);
                }),
              ),
            ),
            Expanded(
              child: Center(
                child: RaisedButton(
                  color: Colors.indigoAccent,
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    // logout so remove this cached data
                    prefs.remove('username');
                    prefs.remove('token');
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
          ],
        ),
      ),
    );
  }
}
