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
        backgroundColor: Colors.indigoAccent,
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

    // TODO request moods from server
    var dataFromServer = {
      "2020/03/06": ["happy at 12:00pm", "sad at 12:01pm", "happy at 12:02pm"],
      "2020/03/07": ["terrible at 3:04pm"],
      "2020/03/10": [
        "sad at 4:04pm",
        "amazing at 7:02pm",
        "okay at 10:00pm",
        "terrible at 10:00pm",
        "happy at 10:00pm"
      ]
    };

    _moodsByDate = {};

    dataFromServer.forEach((k, v) {
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
    } else if (this._mood.contains("terrible")) {
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
        onTap:
            null, // todo can add something here but I don't think it's necessary?
      ),
    );
  }
}
