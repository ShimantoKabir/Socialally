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

}