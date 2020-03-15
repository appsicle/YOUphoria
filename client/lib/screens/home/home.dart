import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../calendar/calendar.dart';
import '../profile/profile.dart';
import '../currentMood/currentMood.dart';

class Home extends StatelessWidget {
  final String username;
  final String token;

  Home({Key key, @required this.username, @required this.token})
      : super(key: key);

  static const String iconFont = 'CupertinoIcons';

  /// The dependent package providing the Cupertino icons font.
  static const String iconFontPackage = 'cupertino_icons';
  static const IconData calendar =
      IconData(0xf2d1, fontFamily: iconFont, fontPackage: iconFontPackage);
  static const IconData mood =
      IconData(0xf38e, fontFamily: iconFont, fontPackage: iconFontPackage);
  static const IconData profile =
      IconData(0xf419, fontFamily: iconFont, fontPackage: iconFontPackage);

  final CupertinoTabController _controller = CupertinoTabController();

  @override
  Widget build(BuildContext context) {
    _controller.index = 1;
    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(items: [
        BottomNavigationBarItem(icon: Icon(calendar), title: Text('Calendar')),
        BottomNavigationBarItem(icon: Icon(mood), title: Text('Mood')),
        BottomNavigationBarItem(icon: Icon(profile), title: Text('Profile'))
      ]),
      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoTabView(
            builder: (context) => Calendar(username: username, token: token),
          );
        } else if (index == 1) {
          return CupertinoTabView(
            builder: (context) => CurrentMood(username: username, token: token),
          );
        } else {
          return CupertinoTabView(
            builder: (context) => Container(
              child: Profile(username: username, token: token),
            ),
          );
        }
      },
    );
  }
}
