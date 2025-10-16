import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';

class Calendar extends StatelessWidget {
  final client = true;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000), // Pure black
              Color(0xFF001020), // Pure black
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CalendarScreen());
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2024, 12, 31),
          focusedDay: _selectedDate,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDate, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
            holidayTextStyle: TextStyle(color: Colors.white),
            selectedDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: Colors.black),
            weekendTextStyle: TextStyle(color: Colors.red),
            weekNumberTextStyle: TextStyle(color: Colors.white),
            defaultTextStyle: TextStyle(color: Colors.white),
            outsideTextStyle: TextStyle(color: Colors.white),
            outsideDaysVisible: false, // Hide days outside the current month
          ),
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(formatButtonVisible: false),
        ),
        if (_selectedDate.year == 2024 &&
            _selectedDate.month == 3 &&
            _selectedDate.day == 15)
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(100, 32, 1, 75).withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.white.withOpacity(0.1),
                      child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.all(0),
                                  child: Text(
                                    "Battle of Hindus",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.07,
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal),
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "JHC ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.07,
                                          ),
                                        ),
                                        Text(
                                          " CHC",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.07,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset("assets/images/jhc.png",
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.23,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.23),
                                        Image.asset(
                                          "assets/images/chc.png",
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.23,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.23,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.045,
                                    )
                                  ],
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              )),
      ],
    ));
  }
}
