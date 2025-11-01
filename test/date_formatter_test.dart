import 'package:flutter_test/flutter_test.dart';
import 'package:chatapp/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formats timestamp correctly', () {
      final formatted = DateFormatter.formatMessageTime(
        DateTime(2025, 10, 31, 9, 15),
      );
      expect(formatted, '09:15 AM');
    });

    test('formats afternoon time correctly', () {
      final formatted = DateFormatter.formatMessageTime(
        DateTime(2025, 10, 31, 14, 30),
      );
      expect(formatted, '02:30 PM');
    });

    test('formats last seen correctly for recent time', () {
      final now = DateTime.now();
      final recent = now.subtract(const Duration(minutes: 5));
      final formatted = DateFormatter.formatLastSeen(recent);
      expect(formatted, '5m ago');
    });

    test('formats last seen as "Just now" for very recent time', () {
      final now = DateTime.now();
      final recent = now.subtract(const Duration(seconds: 30));
      final formatted = DateFormatter.formatLastSeen(recent);
      expect(formatted, 'Just now');
    });
  });
}


