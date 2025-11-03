import 'package:flutter_test/flutter_test.dart';
import 'package:test_project/core/utils/date_formatter.dart';
import 'package:test_project/core/utils/message_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatMessageTime returns correct time format', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30);
      final result = DateFormatter.formatMessageTime(dateTime);
      expect(result, '2:30 PM');
    });

    test('formatMessageTime handles AM correctly', () {
      final dateTime = DateTime(2024, 1, 15, 9, 15);
      final result = DateFormatter.formatMessageTime(dateTime);
      expect(result, '9:15 AM');
    });

    test('formatChatListTime returns "Today" for today\'s messages', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 30);
      final result = DateFormatter.formatChatListTime(today);
      expect(result, contains(':'));
      expect(result, contains('M'));
    });

    test(
      'formatChatListTime returns "Yesterday" for yesterday\'s messages',
      () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = DateFormatter.formatChatListTime(yesterday);
        expect(result, 'Yesterday');
      },
    );

    test('formatChatListTime returns day name for messages within a week', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final result = DateFormatter.formatChatListTime(threeDaysAgo);
      expect(result.length, greaterThan(0));
    });

    test('formatFullDateTime returns complete date and time', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30);
      final result = DateFormatter.formatFullDateTime(dateTime);
      expect(result, contains('Jan'));
      expect(result, contains('15'));
      expect(result, contains('2024'));
      expect(result, contains('at'));
    });

    test('formatRelativeTime returns "Just now" for recent messages', () {
      final now = DateTime.now();
      final result = DateFormatter.formatRelativeTime(now);
      expect(result, 'Just now');
    });

    test(
      'formatRelativeTime returns minutes ago for messages within an hour',
      () {
        final fiveMinutesAgo = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        final result = DateFormatter.formatRelativeTime(fiveMinutesAgo);
        expect(result, '5 minutes ago');
      },
    );

    test('formatRelativeTime returns hours ago for messages within a day', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      final result = DateFormatter.formatRelativeTime(twoHoursAgo);
      expect(result, '2 hours ago');
    });

    test('formatRelativeTime handles singular minute correctly', () {
      final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
      final result = DateFormatter.formatRelativeTime(oneMinuteAgo);
      expect(result, '1 minute ago');
    });

    test('formatRelativeTime handles singular hour correctly', () {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final result = DateFormatter.formatRelativeTime(oneHourAgo);
      expect(result, '1 hour ago');
    });
  });

  group('MessageFormatter Tests', () {
    test('truncateMessage returns full message if under max length', () {
      const message = 'Hello, World!';
      final result = MessageFormatter.truncateMessage(message);
      expect(result, 'Hello, World!');
    });

    test('truncateMessage truncates long messages', () {
      const message =
          'This is a very long message that should be truncated because it exceeds the maximum length';
      final result = MessageFormatter.truncateMessage(message, maxLength: 20);
      expect(result, 'This is a very long ...');
      expect(result.length, 23); // 20 + '...'
    });

    test('formatMessagePreview returns emoji for image messages', () {
      final result = MessageFormatter.formatMessagePreview(
        'image.jpg',
        'image',
      );
      expect(result, '📷 Photo');
    });

    test('formatMessagePreview returns emoji for video messages', () {
      final result = MessageFormatter.formatMessagePreview(
        'video.mp4',
        'video',
      );
      expect(result, '🎥 Video');
    });

    test('formatMessagePreview returns truncated text for text messages', () {
      const longMessage =
          'This is a very long text message that should be truncated';
      final result = MessageFormatter.formatMessagePreview(longMessage, 'text');
      expect(result.length, lessThanOrEqualTo(53)); // 50 + '...'
    });

    test('isValidMessage returns true for non-empty messages', () {
      expect(MessageFormatter.isValidMessage('Hello'), true);
      expect(MessageFormatter.isValidMessage('  Hello  '), true);
    });

    test('isValidMessage returns false for empty messages', () {
      expect(MessageFormatter.isValidMessage(''), false);
      expect(MessageFormatter.isValidMessage('   '), false);
    });

    test('sanitizeMessage removes leading and trailing whitespace', () {
      expect(MessageFormatter.sanitizeMessage('  Hello  '), 'Hello');
      expect(MessageFormatter.sanitizeMessage('Hello'), 'Hello');
      expect(MessageFormatter.sanitizeMessage('  '), '');
    });
  });
}
