import 'package:flutter_test/flutter_test.dart';
import 'package:chat/utils/time_utils.dart';

void main() {
  group('TimeUtils', () {
    group('formatMessageTime', () {
      test('formats timestamp correctly for AM time', () {
        final timestamp = DateTime(2024, 1, 1, 9, 30);
        final formatted = TimeUtils.formatMessageTime(timestamp);
        expect(formatted, matches(RegExp(r'\d{1,2}:\d{2}\s+(AM|PM)')));
      });

      test('formats timestamp correctly for PM time', () {
        final timestamp = DateTime(2024, 1, 1, 15, 45);
        final formatted = TimeUtils.formatMessageTime(timestamp);
        expect(formatted, matches(RegExp(r'\d{1,2}:\d{2}\s+(AM|PM)')));
      });

      test('formats midnight correctly', () {
        final timestamp = DateTime(2024, 1, 1, 0, 0);
        final formatted = TimeUtils.formatMessageTime(timestamp);
        expect(formatted, contains('AM'));
      });

      test('formats noon correctly', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0);
        final formatted = TimeUtils.formatMessageTime(timestamp);
        expect(formatted, contains('PM'));
      });
    });

    group('formatChatListTime', () {
      test('formats timestamp correctly', () {
        final timestamp = DateTime(2024, 1, 1, 14, 30);
        final formatted = TimeUtils.formatChatListTime(timestamp);
        expect(formatted, matches(RegExp(r'\d{1,2}:\d{2}\s+(AM|PM)')));
      });
    });

    group('timeAgo', () {
      test('returns "just now" for recent time', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(seconds: 30));
        expect(TimeUtils.timeAgo(time), equals('just now'));
      });

      test('returns minutes ago for time less than an hour', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(minutes: 30));
        expect(TimeUtils.timeAgo(time), equals('30m ago'));
      });

      test('returns hours ago for time less than a day', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(hours: 5));
        expect(TimeUtils.timeAgo(time), equals('5h ago'));
      });

      test('returns days ago for time less than a week', () {
        final now = DateTime.now();
        final time = now.subtract(const Duration(days: 3));
        expect(TimeUtils.timeAgo(time), equals('3d ago'));
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        final now = DateTime.now();
        expect(TimeUtils.isToday(now), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(TimeUtils.isToday(yesterday), isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(TimeUtils.isToday(tomorrow), isFalse);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(TimeUtils.isYesterday(yesterday), isTrue);
      });

      test('returns false for today', () {
        final now = DateTime.now();
        expect(TimeUtils.isYesterday(now), isFalse);
      });

      test('returns false for two days ago', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(TimeUtils.isYesterday(twoDaysAgo), isFalse);
      });
    });
  });
}

