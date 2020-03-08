import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';
import '../currentMood/happinessData.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  List<String> _selectedActivities = [];
  final List<String> _possibleActivities =
      HappinessData.getPossibleActivities();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            height: 175,
            alignment: Alignment.bottomCenter,
            child: Text(
              "Enter in some interests so we can start making personalized recommendations for you!",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 25.0),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                children: List.generate(10, (index) {
                  return Container(
                    height: 20,
                    width: 30,
                    child: ActivityButton(_possibleActivities[index], () {
                      setState(() {
                        String act = _possibleActivities[index];
                        if (_selectedActivities.contains(act)) {
                          _selectedActivities.remove(act);
                        } else {
                          _selectedActivities.add(act);
                        }
                        print(_selectedActivities);
                      });
                    }),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              // color: Colors.blueGrey,
              alignment: Alignment.topCenter,
              child: CupertinoButton(
                color: Colors.blueGrey,
                disabledColor: Colors.grey[300],
                onPressed: _selectedActivities.length > 0
                    ? () {
                        // TODO: send mood data to backend with selected activites
                        Navigator.of(context, rootNavigator: true)
                            .pushReplacement(MaterialPageRoute(
                                builder: (BuildContext ctx) => new Home()));
                        if (_selectedActivities.length > 0) {
                          print(_selectedActivities);
                        }
                      }
                    : null,
                child: Text('Confirm Selection'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
