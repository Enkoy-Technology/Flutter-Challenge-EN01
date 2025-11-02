import 'package:intl/intl.dart';

class TimeUtils {
  TimeUtils._();

  static String formatMessageTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  static String formatChatListTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  static String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    
    if (diff.inMinutes < 1) {
      return 'just now';
    }
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    
    if (diff.inDays < 365) {
      return DateFormat('MMM d').format(time);
    }
    
    return DateFormat('MMM d, y').format(time);
  }

  static bool isToday(DateTime timestamp) {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  static bool isYesterday(DateTime timestamp) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day;
  }
}

