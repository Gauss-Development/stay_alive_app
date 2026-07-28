import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
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
  }) : _account = account,
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
    final appwrite_models.DocumentList documents = await _databases
        .listDocuments(
          databaseId: _envConfig.appwriteDatabaseId,
          collectionId: _envConfig.dailyLogsCollectionId,
          queries: <String>[
            Query.greaterThanEqual('log_date', _dateKey(startDate)),
            Query.lessThanEqual('log_date', _dateKey(endDate)),
            Query.orderAsc('log_date'),
            Query.limit(100),
          ],
        );

    return documents.documents
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
