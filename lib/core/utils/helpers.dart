import 'package:intl/intl.dart';

class Helpers {
  static String formatTimestamp(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}
