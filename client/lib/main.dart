import 'package:flutter/material.dart';
import 'screens/home/home.dart';
import 'screens/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CupertinoApp(
    home: DetermineScreen(),
    localizationsDelegates: <LocalizationsDelegate<dynamic>>[
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
    ],
  ));
}

Future<Response> postData(endpoint, json, token) async {
  var headers = {"Content-type": "application/json"};
  if (token != null) {
    headers["token"] = token;
  }
  Response response = await post('http://localhost:8080/' + endpoint,
      headers: headers, body: jsonEncode(json));
  return response;
}

Future<Response> getData(endpoint, json, token) async {
  var headers = {"Content-type": "application/json"};
  if (token != null) {
    headers["token"] = token;
  }
  Response response =
      await get('http://localhost:8080/' + endpoint, headers: headers);
  return response;
}

class DetermineScreen extends StatefulWidget {
  @override
  _DetermineScreenState createState() => _DetermineScreenState();
}

class _DetermineScreenState extends State<DetermineScreen> {
  Widget toDisplay = Container();
  @override
  void initState() {
    checkIfLoggedIn();
    super.initState();
  }

  Future checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    String token = prefs.getString('token');
    if (username != null) {
      setState(() {
        toDisplay = Home(username: username, token: token);
      });
    } else {
      setState(() {
        toDisplay = Login();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return toDisplay;
  }
}
