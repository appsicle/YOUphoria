import 'package:flutter/material.dart';
import 'screens/home/home.dart';
import 'screens/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class DetermineScreen extends StatefulWidget {
  @override
  _DetermineScreenState createState() => _DetermineScreenState();
}

class _DetermineScreenState extends State<DetermineScreen> {
  Widget toDisplay = Container();
  @override
  void initState() {
    checkIfLoggedIn().then((value) {
      // print("async done");
    });
    super.initState();
  }

  Future checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    if (username != null) {
      // print("logged in");
      setState(() {
        toDisplay = Home(username: username);
      });
    } else {
      // print("logged out");
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
