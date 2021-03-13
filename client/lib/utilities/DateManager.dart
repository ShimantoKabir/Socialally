import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateManager{

  static DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  static String findFirstDateOfTheWeek(DateTime dateTime) {
    DateTime startDateTime = dateTime.subtract(Duration(days: dateTime.weekday - 1));
    return dateFormat.format(startDateTime);
  }

  static String findLastDateOfTheWeek(DateTime dateTime) {
    DateTime endDateTime = dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
    return dateFormat.format(endDateTime);
  }

  static getOnlyDate(DateTime dateTime){
    return dateFormat.format(dateTime);
  }

  static TimeOfDay getTimeOfDayFromString(String time) {
    int hh = 0;
    if (time.endsWith('PM')) hh = 12;
    time = time.split(' ')[0];
    return TimeOfDay(
      hour: hh + int.parse(time.split(":")[0]) % 24, // in case of a bad time format entered manually by the user
      minute: int.parse(time.split(":")[1]) % 60,
    );
  }

}