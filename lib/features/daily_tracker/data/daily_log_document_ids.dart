/// Deterministic Appwrite document ids for daily logs.
///
/// The deployed Stay Alive database does not expose `log_date` / `user_id`
/// attributes on `daily_logs`, so each user's log for a calendar day is stored
/// as a document with id `{userId}_{yyyy-MM-dd}` and row-level permissions.
abstract final class DailyLogDocumentIds {
  static final RegExp _dateKeyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static String log(String userId, String dateKey) => '${userId}_$dateKey';

  static String item(String logDocumentId, String categoryId) =>
      '${logDocumentId}_$categoryId';

  static String? dateKeyFromLogDocumentId(String documentId) {
    final int separator = documentId.lastIndexOf('_');
    if (separator <= 0 || separator >= documentId.length - 1) {
      return null;
    }
    final String dateKey = documentId.substring(separator + 1);
    return _dateKeyPattern.hasMatch(dateKey) ? dateKey : null;
  }

  static String? userIdFromLogDocumentId(String documentId) {
    final int separator = documentId.lastIndexOf('_');
    if (separator <= 0) {
      return null;
    }
    return documentId.substring(0, separator);
  }

  static bool isItemForLog(String itemDocumentId, String logDocumentId) {
    return itemDocumentId.startsWith('${logDocumentId}_');
  }
}
