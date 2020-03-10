import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../createAccount/createAccount.dart';
import '../home/home.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Login extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  // Username requirements: Only allowed alphanumeric characters and '_', between 5 and 14 characters
  final RegExp validUsernameExpression = new RegExp(r'^[a-zA-Z0-9_]{5,14}$');
  // Password requirements: 1 letter, 1 number, 1 special character, between 8 and 20 characters
  final RegExp validPasswordExpression = new RegExp(
      r'^(?=(?:[^a-z]*[a-z]){1})(?=(?:[^0-9]*[0-9]){1})(?=.*[!-\/:-@\[-`{-~]).{8,20}$');

  @override
  Widget build(BuildContext context) {
    Material _createButton(text, color, onPressed) {
      return Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: color,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: onPressed,
          child: Text(text,
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

    // TODO make login function
    void _login() async {
      String username = usernameTextController.text;
      String password = passwordTextController.text;

      // TODO pass this information to backend and do next steps based on result
      // option 1: invalid username and password notifcation and return

      // option 2: redirect to home page
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext ctx) => new Home(username: username)));
    }

    // void postDate()

    // TODO make create account function
    void _createAccount() async {
      String username = usernameTextController.text;
      String password = passwordTextController.text;

      // TODO uncomment this out when ready to actually check for valid username/password (commented out for easier testing)
      // if (!validUsernameExpression.hasMatch(username)) {
      //   showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       title: Text("Oop! Username Invalid!"),
      //       content: Text(
      //           "Username requirements: Only allowed alphanumeric characters and '_', between 5 and 14 characters."),
      //     ),
      //     barrierDismissible: true,
      //   );
      //   return;
      // }

      // if (!validPasswordExpression.hasMatch(password)) {
      //   showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       title: Text("Yikes! Password Invalid!"),
      //       content: Text(
      //           "Password requirements: 1 letter, 1 number, 1 special character, between 8 and 20 characters"),
      //     ),
      //     barrierDismissible: true,
      //   );
      //   return;
      // }
      var loginInformation = {"username": username, "password": password};
      String url = 'http://localhost:8080/profile/create';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json = jsonEncode(loginInformation);
      Response response = await post(url, headers: headers, body: json);
      int statusCode = response.statusCode;
      // print(statusCode);
      var body = jsonDecode(response.body);
      // print(body);

      if (statusCode == 200) {
      String token = body["token"];
      // provide token to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);
      prefs.setString('token', token);

      // redirect page to interest selection to finish creating account
      // TODO should also be passing in token
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext ctx) =>
                  new CreateAccount(username: username)));
      } else { // error in account creation, duplicate username

      }
    }

    final usernameField = TextField(
      controller: usernameTextController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      controller: passwordTextController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButton = _createButton("Login", Colors.indigoAccent, _login);
    final createAccountButton =
        _createButton("Create Account", Colors.indigoAccent, _createAccount);

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100.0,
                  child: Center(
                    child: Text(
                      "YOUphoria",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  // child: Image.asset(
                  //   "assets/logo.png", // TODO provide logo
                  //   fit: BoxFit.contain,
                  // ),
                ),
                SizedBox(height: 30.0),
                usernameField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButton,
                SizedBox(
                  height: 15.0,
                ),
                createAccountButton,
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
