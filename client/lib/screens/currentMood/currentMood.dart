import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CurrentMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AddMood(),
    );
  }
}

class AddMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Center(
        child: CupertinoButton(
            onPressed: () {
              // Add your onPressed code here!
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => NewMood(),
              ));
            },
            child: Text('Add Mood'),
            color: CupertinoColors.darkBackgroundGray),
      ),
    );
  }
}

class NewMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Mood'),
      ),
      child: CupertinoButton(child: Text('testtt'), onPressed: null,),
      backgroundColor: CupertinoColors.lightBackgroundGray,
    );
  }
}

// class StarDisplay extends StatelessWidget {
//   final int value;
//   const StarDisplay({Key key, this.value = 0})
//       : assert(value != null),
//         super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       // mainAxisSize: MainAxisSize.min,
//       children: List.generate(5, (index) {
//         return Icon(
//           index < value ? Icons.star : Icons.star_border,
//         );
//       }),
//     );
//   }
// }
