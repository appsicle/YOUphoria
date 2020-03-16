import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'userInterests.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final format = DateFormat("yyyy-MM-dd");
  String _birthday = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String _gender = "male";
  final zipcodeController = TextEditingController();

  _CreateAccountState(this._username, this._token);

  @override
  void initState() {
    setCurrentStateOfScreen();
    super.initState();
  }

  void setCurrentStateOfScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("createAccount", "true");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.fromLTRB(25.0, 15.0, 20.0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 15.0),
              child: Text(
                "Tell us about yourself!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Gender:     ",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                Expanded(
                  child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text("Select"),
                      items: [
                        DropdownMenuItem<String>(
                          value: "male",
                          child: Text(
                            "male",
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: "female",
                          child: Text(
                            "female",
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: "other",
                          child: Text(
                            "other",
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                      value: _gender,
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue;
                          print(_gender);
                        });
                      }),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Birthday:  ",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  MaterialButton(
                    child: Text(
                      "$_birthday",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    elevation: 10.0,
                    color: Colors.indigo,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext builder) {
                          return Container(
                            height:
                                MediaQuery.of(context).copyWith().size.height /
                                    3,
                            child: CupertinoDatePicker(
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (DateTime date) {
                                setState(() {
                                  _birthday =
                                      DateFormat("yyyy-MM-dd").format(date);
                                });
                              },
                              maximumDate: DateTime.now(),
                              minimumYear: 1950,
                              maximumYear: 2020,
                              mode: CupertinoDatePickerMode.date,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0),
              child: TextField(
                controller: zipcodeController,
                obscureText: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "Zipcode",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
              ),
            ),
            SizedBox(height: 25.0),
            Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.cyan,
              child: MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                onPressed: () async {
                  // TODO use API call endpoint to send them info of gender, birthday, and zipcode
                  String zipcode = zipcodeController.text.trim();
                  print(zipcode);
                  print(_gender);
                  print(_birthday);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('createAccount');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext ctx) => new UserInterests(
                        username: _username,
                        token: _token,
                      ),
                    ),
                  );
                },
                child: Text("Submit",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
