import 'package:intl/intl.dart';

class DateFormatter {
  /// Formats a DateTime to a readable time string
  /// Examples: "10:30 AM", "2:45 PM"
  static String formatMessageTime(DateTime dateTime) {
    // Convert UTC to local time
    final localTime = dateTime.toLocal();
    return DateFormat('h:mm a').format(localTime);
  }

  /// Formats a DateTime to show date and time
  /// Examples: "Today 10:30 AM", "Yesterday 2:45 PM", "Jan 15, 2:45 PM"
  static String formatChatListTime(DateTime dateTime) {
    // Convert UTC to local time
    final localTime = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      localTime.year,
      localTime.month,
      localTime.day,
    );

    if (messageDate == today) {
      return formatMessageTime(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(localTime).inDays < 7) {
      return DateFormat('EEEE').format(localTime); // Day name
    } else {
      return DateFormat('MMM d').format(localTime);
    }
  }

  /// Formats a DateTime to show full date and time
  /// Example: "Jan 15, 2024 at 10:30 AM"
  static String formatFullDateTime(DateTime dateTime) {
    // Convert UTC to local time
    final localTime = dateTime.toLocal();
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(localTime);
  }

  /// Formats a DateTime to show relative time
  /// Examples: "Just now", "5 minutes ago", "2 hours ago"
  static String formatRelativeTime(DateTime dateTime) {
    // Convert UTC to local time
    final localTime = dateTime.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return formatChatListTime(dateTime);
    }
  }
}
