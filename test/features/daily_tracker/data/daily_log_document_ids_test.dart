import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/core/appwrite/appwrite_document_ids.dart';
import 'package:stay_alive/features/daily_tracker/data/daily_log_document_ids.dart';

void main() {
  group('AppwriteDocumentIds', () {
    test('deterministic ids are valid and within 36 chars', () {
      final String id = AppwriteDocumentIds.deterministic('seed');
      expect(id.length, lessThanOrEqualTo(36));
      expect(AppwriteDocumentIds.isValid(id), isTrue);
    });
  });

  group('DailyLogDocumentIds', () {
    test('builds valid log ids for standard Appwrite user ids', () {
      const String userId = '67a1b2c3d4e5f6789012';
      const String dateKey = '2026-05-06';
      final String logId = DailyLogDocumentIds.log(userId, dateKey);

      expect(logId, '${userId}_$dateKey');
      expect(AppwriteDocumentIds.isValid(logId), isTrue);
    });

    test('hashes item ids so long category slugs stay valid', () {
      const String logId = '67a1b2c3d4e5f6789012_2026-05-06';
      final String itemId = DailyLogDocumentIds.item(
        logDocumentId: logId,
        categoryId: 'cruciferous_vegetables',
      );

      expect(itemId.length, lessThanOrEqualTo(36));
      expect(AppwriteDocumentIds.isValid(itemId), isTrue);
      expect(
        DailyLogDocumentIds.item(
          logDocumentId: logId,
          categoryId: 'cruciferous_vegetables',
        ),
        itemId,
      );
    });

    test('parses user and date from composite log document id', () {
      expect(
        DailyLogDocumentIds.userIdFromLogDocumentId('user_1_2026-05-06'),
        'user_1',
      );
      expect(
        DailyLogDocumentIds.dateKeyFromLogDocumentId('user_1_2026-05-06'),
        '2026-05-06',
      );
    });
  });
}
