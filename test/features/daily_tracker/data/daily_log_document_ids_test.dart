import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/features/daily_tracker/data/daily_log_document_ids.dart';

void main() {
  group('DailyLogDocumentIds', () {
    test('builds deterministic log and item ids', () {
      expect(
        DailyLogDocumentIds.log('user_1', '2026-05-06'),
        'user_1_2026-05-06',
      );
      expect(
        DailyLogDocumentIds.item('user_1_2026-05-06', 'beans'),
        'user_1_2026-05-06_beans',
      );
    });

    test('parses user and date from log document id', () {
      expect(
        DailyLogDocumentIds.userIdFromLogDocumentId('user_1_2026-05-06'),
        'user_1',
      );
      expect(
        DailyLogDocumentIds.dateKeyFromLogDocumentId('user_1_2026-05-06'),
        '2026-05-06',
      );
    });

    test('matches item documents to parent log', () {
      expect(
        DailyLogDocumentIds.isItemForLog(
          'user_1_2026-05-06_cruciferous_vegetables',
          'user_1_2026-05-06',
        ),
        isTrue,
      );
      expect(
        DailyLogDocumentIds.isItemForLog(
          'user_1_2026-05-07_beans',
          'user_1_2026-05-06',
        ),
        isFalse,
      );
    });
  });
}
