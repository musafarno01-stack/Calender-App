import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/utils/date_utils.dart';

void main() {
  group('DayflowDates', () {
    test('dateOnly removes the time component', () {
      final result = DayflowDates.dateOnly(
        DateTime(2028, 5, 10, 18, 45),
      );

      expect(result, DateTime(2028, 5, 10));
    });

    test('isSameDay ignores time', () {
      expect(
        DayflowDates.isSameDay(
          DateTime(2028, 5, 10, 8),
          DateTime(2028, 5, 10, 21),
        ),
        isTrue,
      );
    });

    test('startOfWeek uses Monday by default', () {
      expect(
        DayflowDates.startOfWeek(DateTime(2028, 5, 10)),
        DateTime(2028, 5, 8),
      );
    });

    test('startOfWeek supports Sunday as first day', () {
      expect(
        DayflowDates.startOfWeek(
          DateTime(2028, 5, 10),
          weekStartsOn: DateTime.sunday,
        ),
        DateTime(2028, 5, 7),
      );
    });

    test('startOfWeek rejects invalid weekday', () {
      expect(
        () => DayflowDates.startOfWeek(
          DateTime(2028, 5, 10),
          weekStartsOn: 8,
        ),
        throwsArgumentError,
      );
    });

    test('adding one month clamps January 31 to February end', () {
      expect(
        DayflowDates.addMonthsClamped(DateTime(2028, 1, 31), 1),
        DateTime(2028, 2, 29),
      );
    });

    test('overdue is false when there is no deadline', () {
      expect(
        DayflowDates.isOverdue(null),
        isFalse,
      );
    });

    test('overdue compares against the supplied current time', () {
      final now = DateTime(2028, 5, 10, 12);

      expect(
        DayflowDates.isOverdue(
          DateTime(2028, 5, 10, 11),
          now: now,
        ),
        isTrue,
      );

      expect(
        DayflowDates.isOverdue(
          DateTime(2028, 5, 10, 13),
          now: now,
        ),
        isFalse,
      );
    });
  });
}
