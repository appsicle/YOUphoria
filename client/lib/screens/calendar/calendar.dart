//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};

void main() {
  initializeDateFormatting().then((_) => runApp(Calendar()));
}

void addMood(DateTime date, mood) {}

class Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Center(
        child: CalendarPage(),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  Map<DateTime, List> _moodsByDate;
  List _selectedMoods;
  AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    // TODO: when user adds new mood, add new event
    // TODO: rename events to moods
    // _moodsByDate = {
    //   new DateFormat("dd/MM/yyyy HH:mm:ss").parse('2020-03-5 12:00:00'): [
    //     'happy:12:04PM'
    //   ],
    //   new DateFormat("dd/MM/yyyy HH:mm:ss").parse('2020-03-6 12:00:00'): [
    //     'happy:12:04PM'
    //   ],
    // };
    // d0 = DateTime.now();

    // todo request moods from server
    var dataFromServer = {
      "2020/03/06": ["happy at 12:00pm", "sad at 12:01pm", "happy at 12:02pm"],
      "2020/03/07": ["happy at 3:04pm"],
      "2020/03/10": ["sad at 4:04pm", "happy at 7:02pm", "okay at 10:00pm"]};

    _moodsByDate = {
    };

    dataFromServer.forEach((k,v) {
      var date = new DateFormat("yyyy/MM/dd", "en_US").parse(k);
      _moodsByDate[date] = v;
    });

    _selectedMoods = _moodsByDate[_selectedDay] ?? [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    print(day);
    setState(() {
      _selectedMoods = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void addEvent() {
    // print();

    var now = new DateTime.now();
    print(new DateFormat("h:mm a", "en_US").parse("12:08 PM"));
    print(new DateFormat("dd-MM-yyyy hh:mm:ss")
        .format(now)); // => 21-04-2019 02:40:25
    print(DateTime.parse("1996-07-20 20:18:04"));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        // Switch out 2 lines below to play with TableCalendar's settings
        //-----------------------
        Container(
          child: FlatButton(
            onPressed: addEvent,
            child: Text('asd'),
          ),
        ),
        _buildTableCalendar(),
        // _buildTableCalendarWithBuilders(),
        Expanded(child: _buildEventList()),
      ],
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _moodsByDate,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.lightBlueAccent,
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedMoods
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }
}
