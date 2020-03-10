import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login.dart';

// TODO finalize what is going to go on this screen and DO IT
class Profile extends StatelessWidget {
  final String username;
  final String token;

  Profile({Key key, @required this.username, @required this.token})
      : super(key: key);

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
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 6,
              child: ListView(
                padding: const EdgeInsets.all(0.0),
                children: [
                  profileData("Username: " + this.username),
                  profileData("placeholder"),
                  profileData("placeholder"),
                  profileData("placeholder"),
                  profileData("placeholder"),
                ],
              ),
            ),
            Expanded(
              flex: 3,
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
