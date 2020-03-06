import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HappinessData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: EnterMoodData(),
    );
  }
}

// TODO make this screen be a place for users to add additional information on why they are in a good mood
class EnterMoodData extends StatefulWidget {
  @override
  _EnterMoodDataState createState() => _EnterMoodDataState();
}

class _EnterMoodDataState extends State<EnterMoodData> {
  List<String> _selectedActivities = [];

  @override
  Widget build(BuildContext context) {
    final List<String> _possibleActivities = [
      "Exercising",
      "Partying",
      "Playing Sports",
      "Playing Video Games",
      "Cooking",
      "Watching Movies",
      "Shopping",
      "Spending Time with Family",
      "Hiking",
      "Working"
    ];
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Why were you happy?'),
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            // height: 1000,

            flex: 9,
            child: Container(
              padding: EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
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
                        // TODO: send selected activites to backend
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        // should never not be 0 because we disable the button but just in case i guess
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

class ActivityButton extends StatefulWidget {
  final String name;
  final Function onPressed;

  const ActivityButton(this.name, this.onPressed);

  @override
  _ActivityButtonState createState() => _ActivityButtonState();
}

class _ActivityButtonState extends State<ActivityButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(10.0),
      borderRadius: BorderRadius.circular(15.0),
      color: this._isSelected ? Colors.greenAccent : Colors.grey[50],
      onPressed: () {
        widget.onPressed();
        setState(() {
          this._isSelected = !this._isSelected;
        });
      },
      child: Center(
        child: Text(
          widget.name,
          style: TextStyle(color: Colors.black, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
