import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Time Formatting Logic', () {
    test('formats afternoon timestamp correctly to h:mm a format', () {
      final dateTime = DateTime(2024, 5, 21, 14, 30);
      final timestamp = Timestamp.fromDate(dateTime);
      const expectedFormat = '2:30 PM';

      final formattedTime = DateFormat('h:mm a').format(timestamp.toDate());

      expect(formattedTime, expectedFormat);
    });

    test('formats morning timestamp correctly to h:mm a format', () {
      final dateTime = DateTime(2024, 5, 21, 9, 5);
      final timestamp = Timestamp.fromDate(dateTime);
      const expectedFormat = '9:05 AM';

      final formattedTime = DateFormat('h:mm a').format(timestamp.toDate());

      expect(formattedTime, expectedFormat);
    });

    test('formats noon timestamp correctly to h:mm a format', () {
      final dateTime = DateTime(2024, 5, 21, 12, 0);
      final timestamp = Timestamp.fromDate(dateTime);
      const expectedFormat = '12:00 PM';

      final formattedTime = DateFormat('h:mm a').format(timestamp.toDate());

      expect(formattedTime, expectedFormat);
    });
  });
}
