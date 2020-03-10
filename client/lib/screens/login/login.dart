import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../createAccount/createAccount.dart';
import '../home/home.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:client/main.dart';

class Login extends StatelessWidget {

  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final usernameTextController = TextEditingController();

  final passwordTextController = TextEditingController();

  final RegExp validUsernameExpression = new RegExp(r'^[a-zA-Z0-9_]{5,14}$');

  final RegExp validPasswordExpression = new RegExp(
      r'^(?=(?:[^a-z]*[a-z]){1})(?=(?:[^0-9]*[0-9]){1})(?=.*[!-\/:-@\[-`{-~]).{8,20}$');

  

  @override
  Widget build(BuildContext context) {
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

    void _login() async {
      String username = usernameTextController.text.trim();
      String password = passwordTextController.text.trim();

      var loginInformation = {"username": username, "password": password};
      Response response = await postData("profile/login", loginInformation);
      var body = jsonDecode(response.body);

      // SUCCESS -> redirect to homepage
      if (response.statusCode == 200) {
        String token = body["token"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('token', token);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext ctx) =>
                    new Home(username: username, token: token)));
      } else {
        // TODO: FAIL -> display fail on screen
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Incorrect username/password"),
          ),
          barrierDismissible: true,
        );
        print('login failed');
      }
    }

    // TODO make create account function
    void _createAccount() async {
      String username = usernameTextController.text.trim();
      String password = passwordTextController.text.trim();

      // TODO uncomment this out when ready to actually check for valid username/password (commented out for easier testing)
      // if (!validUsernameExpression.hasMatch(username)) {
        // showDialog(
        //   context: context,
        //   builder: (_) => AlertDialog(
        //     title: Text("Oop! Username Invalid!"),
        //     content: Text(
        //         "Username requirements: Only allowed alphanumeric characters and '_', between 5 and 14 characters."),
        //   ),
        //   barrierDismissible: true,
        // );
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

      var createAccountInformation = {
        "username": username,
        "password": password
      };
      Response response =
          await postData("profile/create", createAccountInformation);
      var body = jsonDecode(response.body);

      // SUCCESS -> redirect to create account page (to send interests)
      if (response.statusCode == 200) {
        String token = body["token"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('token', token);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext ctx) =>
                    new CreateAccount(username: username, token: token)));
      } else {
        // TODO: FAIL -> error in account creation, duplicate username, display this to the user somehow
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("That username has been taken"),
          ),
          barrierDismissible: true,
        );
      }
    }

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
