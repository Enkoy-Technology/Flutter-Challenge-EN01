import 'package:flutter_test/flutter_test.dart';
import 'package:messaging_app/common/utils/time_formatter.dart';

void main() {
  group('TimeFormatter Tests', () {
    test('formatMessageTime returns HH:mm for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 14, 30);
      
      final result = TimeFormatter.formatMessageTime(today);
      
      expect(result, '14:30');
    });

    test('formatMessageTime returns Yesterday for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      final result = TimeFormatter.formatMessageTime(yesterday);
      
      expect(result, 'Yesterday');
    });

    test('formatMessageTime returns day name for this week', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      
      final result = TimeFormatter.formatMessageTime(threeDaysAgo);
      
      expect(result.length, greaterThan(0));
      expect(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
          .contains(result), true);
    });

    test('formatMessageTime returns date for older messages', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 10));
      
      final result = TimeFormatter.formatMessageTime(oldDate);
      
      expect(result, matches(r'\d{2}/\d{2}/\d{4}'));
    });

    test('formatChatListTime returns Now for very recent messages', () {
      final now = DateTime.now();
      
      final result = TimeFormatter.formatChatListTime(now);
      
      expect(result, 'Now');
    });

    test('formatChatListTime returns minutes for recent messages', () {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      
      final result = TimeFormatter.formatChatListTime(fiveMinutesAgo);
      
      expect(result, '5m');
    });

    test('formatChatListTime returns HH:mm for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 15);
      
      final result = TimeFormatter.formatChatListTime(today);
      
      expect(result, '10:15');
    });
  });
}