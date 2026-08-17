import 'package:stay_alive/core/appwrite/appwrite_document_ids.dart';

/// Deterministic Appwrite document ids for daily logs.
///
/// Log ids use `{userId}_{yyyy-MM-dd}` when within Appwrite's 36-char limit;
/// otherwise a deterministic hash. Item ids are always hashed because
/// `{logId}_{categoryId}` exceeds 36 chars for long category slugs.
abstract final class DailyLogDocumentIds {
  static final RegExp _dateKeyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static String log(String userId, String dateKey) {
    final String composite = '${userId}_$dateKey';
    if (AppwriteDocumentIds.isValid(composite)) {
      return composite;
    }
    return AppwriteDocumentIds.deterministic('log|$userId|$dateKey');
  }

  static String item({
    required String logDocumentId,
    required String categoryId,
  }) {
    return AppwriteDocumentIds.deterministic('item|$logDocumentId|$categoryId');
  }

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

  /// Legacy items used `{logDocumentId}_{categoryId}` prefixes before hashing.
  static bool isLegacyItemForLog(String itemDocumentId, String logDocumentId) {
    return itemDocumentId.startsWith('${logDocumentId}_');
  }
}
