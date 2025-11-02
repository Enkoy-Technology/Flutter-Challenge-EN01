// ignore_for_file: depend_on_referenced_packages

import 'package:intl/intl.dart';

class DateTimeUtils {
  static double toDouble(String tm) {
    String mod = tm.split(RegExp(r'\s')).last;
    String time = tm.split(RegExp(r'\s')).first;
    int hour = int.parse(time.split(":").first);
    String minutes = time.split(":")[1];

    if (mod.toUpperCase() == "AM") {
      if (hour == 12) {
        return 12 + int.parse(minutes) / 60;
      }
      return hour + int.parse(minutes) / 60;
    }
    if (hour == 12) {
      return hour + int.parse(minutes) / 60;
    }
    return (12 + hour) + int.parse(minutes) / 60;
  }

  static double toDouble24Hour(String tm) {
    //Formely 24 hours
    String time = tm.split(" ").first;
    int hour = int.parse(time.split(":").first);
    String minutes = time.split(":")[1];
    return hour + int.parse(minutes) / 60;
  }

  static String minutesToTime(int minutes) {
    int hours = (minutes / 60).floor();
    String mins = (((minutes / 60) - hours) * 60).floor().toString();
    return "0$hours:$mins";
  }

  static getShortenFormattedTime(String fullTime) {
    String hour = fullTime.split(":")[0];
    String minutes = fullTime.split(":")[1];
    String mode = fullTime.split(":")[2].split(" ")[1];
    String time = "$hour:$minutes $mode";
    return time;
  }

  static String to24HourStr(String tm) {
    String mod = tm.split(" ").last;
    String time = tm.split(" ").first;
    int hour = int.parse(time.split(":").first);
    String minutes = time.split(":")[1];
    if (mod.toUpperCase() == "AM") {
      if (hour == 12) {
        return "12:$minutes";
      }
      return "${hour.toString().padLeft(2, "0")}:$minutes";
    }
    if (hour == 12) {
      return "$hour:$minutes";
    }
    return "${12 + hour}:$minutes";
  }

  static String dateTimeTo12HourStr(DateTime dateTime) {
    String time = dateTime.toIso8601String().split("T")[1];

    if (time.toLowerCase().contains(RegExp(r'[am]|[pm]'))) {
      //already 12 hour format
      return time;
    }
    int hour = int.parse(time.split(":")[0]);
    String hourStr = time.split(":")[0];
    String minutes = time.split(":")[1];

    String mode = "AM";
    if (hour > 12) {
      mode = "PM";
      hourStr = (hour - 12).toString();
    }
    return "${hourStr.padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $mode";
  }

  static String timeTo12HourStr(String time) {
    if (time.toLowerCase().contains(RegExp(r'[am]|[pm]'))) {
      //already 12 hour format
      return time;
    }
    int hour = int.parse(time.split(":")[0]);
    String hourStr = time.split(":")[0];
    String minutes = time.split(":")[1];

    String mode = "AM";
    if (hour > 12) {
      mode = "PM";
      hourStr = (hour - 12).toString();
    }
    return "${hourStr.padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $mode";
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return "";
    }
    return DateFormat("E, MMM d yyyy").format(dateTime);
  }

  static String getFormattedLastseenStatus(DateTime inputDate) {
    if (DateTime.now().difference(inputDate).inMinutes < 60) {
      return "Last seen in ${DateTime.now().difference(inputDate).inMinutes + 1} minutes";
    } else if (DateTime.now().difference(inputDate).inHours < 24) {
      return "Last seen in ${DateTime.now().difference(inputDate).inHours} hours";
    }
    return "Last seen ${DateFormat("MMM d, h:mm a").format(inputDate)}";
  }

  static String formatDateDashed(DateTime? dateTime) {
    if (dateTime == null) {
      return "";
    }
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

  static String formatDateTime(DateTime? dateTime, {bool includeDay = false}) {
    if (dateTime == null) {
      return "";
    }
    return DateFormat(includeDay ? 'E' : '' "MMM d, yyyy 'at' hh:mm a")
        .format(dateTime);
  }

  static String? toDateTimeString(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  static String formatDayAndMonth(DateTime dateTime) {
    return DateFormat("E, MMM d").format(dateTime);
  }

  static DateTime? parseDateTime(String? val) {
    return DateTime.tryParse(val ?? "");
  }

  static DateTime parseDateTimeV6Order(String? val) {
    return DateFormat("MM/dd/yyy hh:mm:ss a").parse(val!);
  }

  static String toQROrderTime(DateTime dateTime) {
    return DateFormat("MM/dd/yyy hh:mm:ss a").format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  static String getDurations(DateTime start, DateTime end) {
    if (end.difference(start).inDays == 0) {
      return "${end.difference(start).inHours} hour, ${(end.difference(start).inMinutes % 60).toString().padLeft(2, "0")} minutes";
    }
    return "${end.difference(start).inDays} days";
  }

  static String getCurrentDate() {
    return DateTimeUtils.formatDateDashed(DateTime.now());
  }
}
