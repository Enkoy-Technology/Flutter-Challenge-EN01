import 'package:flutter_challenge_en01/core/util/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatter', () {
    group('formatMessageTime', () {
      test('should format time for today as HH:mm', () {
        final now = DateTime.now();
        final result = DateFormatter.formatMessageTime(now);
        expect(result, contains(':'));
      });

      test('should format time for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = DateFormatter.formatMessageTime(yesterday);
        expect(result, contains('Yesterday'));
      });

      test('should format time for older dates as dd/MM/yyyy HH:mm', () {
        final oldDate = DateTime.now().subtract(const Duration(days: 30));
        final result = DateFormatter.formatMessageTime(oldDate);
        expect(result, contains('/'));
      });
    });

    group('formatTimeAgo', () {
      test('should format time ago', () {
        final fiveMinutesAgo =
            DateTime.now().subtract(const Duration(minutes: 5));
        final result = DateFormatter.formatTimeAgo(fiveMinutesAgo);
        expect(result.isNotEmpty, true);
      });
    });
  });
}
