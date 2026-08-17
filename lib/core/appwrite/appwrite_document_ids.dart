import 'dart:convert';

/// Appwrite custom document IDs: max 36 chars, `[A-Za-z0-9._-]`, no leading special char.
abstract final class AppwriteDocumentIds {
  static const int maxLength = 36;

  static String deterministic(String seed) {
    var hash1 = 0x811c9dc5;
    var hash2 = 0x811c9dc5;
    for (final int codeUnit in utf8.encode(seed)) {
      hash1 = (hash1 ^ codeUnit) * 0x01000193;
      hash2 = (hash2 ^ (codeUnit + 31)) * 0x01000193;
    }
    final String id =
        '${(hash1 & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}'
        '${(hash2 & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}';
    assert(id.length <= maxLength);
    return id;
  }

  static bool isValid(String documentId) {
    if (documentId.isEmpty || documentId.length > maxLength) {
      return false;
    }
    final int first = documentId.codeUnitAt(0);
    final bool startsOk =
        (first >= 65 && first <= 90) ||
        (first >= 97 && first <= 122) ||
        (first >= 48 && first <= 57);
    if (!startsOk) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(documentId);
  }
}
