//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:client/http.dart';
import 'dart:convert';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};

class Calendar extends StatelessWidget {
  final String username;
  final String token;

  Calendar({Key key, @required this.username, @required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Center(
        child: CalendarPage(username: username, token: token),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  CalendarPage(
      {Key key, this.title, @required this.username, @required this.token})
      : super(key: key);

  final String title;
  final String username;
  final String token;

  @override
  _CalendarPageState createState() => _CalendarPageState(token);
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  Map<DateTime, List> _moodsByDate;
  List _selectedMoods;
  AnimationController _animationController;
  CalendarController _calendarController;
  final String _token;

  _CalendarPageState(this._token);

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    _moodsByDate = {};

    getCalendarInformation();

    _selectedMoods = _moodsByDate[_selectedDay] ?? [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  void getCalendarInformation() async {
    var response = await getData("mood/getAllMoods", this._token);
    var body = jsonDecode(response.body);
    Map<DateTime, List<String>> dataFromServer = {};
    if (response.statusCode == 200) {
      var data = body["calendar"];
      if (data.length > 0) {
        for (int i = 0; i < data.length; i++) {
          DateTime date =
              new DateFormat("yyyy-MM-dd", "en_US").parse(data[i]["date"]);
          String mood = data[i]["mood"] + " at " + data[i]["time"];
          if (dataFromServer[date] == null) {
            dataFromServer[date] = [mood];
          } else {
            dataFromServer[date].add(mood);
          }
        }
        setState(() {
          _moodsByDate = dataFromServer;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedMoods = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildTableCalendar(),
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
        selectedColor: Colors.greenAccent,
        todayColor: Colors.cyan[100],
        markersColor: Colors.black,
        outsideDaysVisible: false,
        weekendStyle: TextStyle(
          color: Colors.indigo,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle(
          color: Colors.indigo,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventList() {
    return ListView(
      children:
          _selectedMoods.map((event) => SelectedMoodWidget(event)).toList(),
    );
  }
}

class SelectedMoodWidget extends StatelessWidget {
  final String _mood;

  SelectedMoodWidget(this._mood);

  Color _getColor() {
    if (this._mood.contains("amazing")) {
      return Colors.greenAccent[200];
    } else if (this._mood.contains("happy")) {
      return Colors.greenAccent[100];
    } else if (this._mood.contains("okay")) {
      return Colors.cyan[100];
    } else if (this._mood.contains("sad")) {
      return Colors.indigoAccent[100];
    } else if (this._mood.contains("horrible")) {
      return Colors.deepPurpleAccent[100];
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: _getColor(),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          _mood.toString(),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        onTap: null,
      ),
    );
  }
}
