import 'package:flutter/material.dart';
import 'screens/home/home.dart';
import 'screens/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var username = prefs.getString('username');

  runApp(CupertinoApp(
    home: Login(),
    localizationsDelegates: <LocalizationsDelegate<dynamic>>[
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
    ],
  ));
}

class Temp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext ctx) => Login()));
    return Home();
  }
}
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoApp(
//       home: Login(),
//       localizationsDelegates: <LocalizationsDelegate<dynamic>>[
//         DefaultMaterialLocalizations.delegate,
//         DefaultWidgetsLocalizations.delegate,
//         DefaultCupertinoLocalizations.delegate,
//       ],
//     );
//   }
// }
