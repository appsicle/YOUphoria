import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';

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
  String _date;
  String _gender = "male";

  _CreateAccountState(this._username, this._token);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Gender:  ",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                Container(
                  child: DropdownButton<String>(
                      items: [
                        DropdownMenuItem<String>(
                          value: "male",
                          child: Text("male"),
                        ),
                        DropdownMenuItem<String>(
                          value: "female",
                          child: Text("female"),
                        ),
                        DropdownMenuItem<String>(
                          value: "other",
                          child: Text("other"),
                        ),
                      ],
                      value: _gender,
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue;
                        });
                      }),
                ),
              ],
            ),
            Row(
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
                    "$_date",
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
                              MediaQuery.of(context).copyWith().size.height / 3,
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime.now(),
                            onDateTimeChanged: (DateTime date) {
                              setState(() {
                                _date = DateFormat("yyyy-MM-dd").format(date);
                                print(_date);
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
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
