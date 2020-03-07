import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(
        child: RaisedButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.remove('username'); // logout so remove this cached data
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
