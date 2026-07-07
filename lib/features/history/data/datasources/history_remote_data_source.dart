import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/daily_tracker/data/daily_log_document_ids.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<DailyLogModel>> fetchLogs({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class AppwriteHistoryRemoteDataSource implements HistoryRemoteDataSource {
  AppwriteHistoryRemoteDataSource({
    required Account account,
    required Databases databases,
    required EnvConfig envConfig,
  })  : _account = account,
        _databases = databases,
        _envConfig = envConfig;

  final Account _account;
  final Databases _databases;
  final EnvConfig _envConfig;

  @override
  Future<List<DailyLogModel>> fetchLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _account.get();
    final String startKey = _dateKey(startDate);
    final String endKey = _dateKey(endDate);
    final appwrite_models.DocumentList documents = await _databases
        .listDocuments(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogsCollectionId,
      queries: <String>[
        Query.limit(100),
      ],
    );

    final List<appwrite_models.Document> filtered = documents.documents
        .where((appwrite_models.Document document) {
          final String? dateKey =
              DailyLogDocumentIds.dateKeyFromLogDocumentId(document.$id);
          if (dateKey == null) {
            return false;
          }
          return dateKey.compareTo(startKey) >= 0 &&
              dateKey.compareTo(endKey) <= 0;
        })
        .toList(growable: false)
      ..sort(
        (appwrite_models.Document a, appwrite_models.Document b) {
          final String? dateA =
              DailyLogDocumentIds.dateKeyFromLogDocumentId(a.$id);
          final String? dateB =
              DailyLogDocumentIds.dateKeyFromLogDocumentId(b.$id);
          return (dateA ?? '').compareTo(dateB ?? '');
        },
      );

    return filtered
        .map(
          (appwrite_models.Document document) => DailyLogModel.fromDocument(
            document: document,
            items: const <DailyLogItemModel>[],
          ),
        )
        .toList(growable: false);
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
