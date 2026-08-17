import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/logger/app_logger.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_item_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/daily_log_model.dart';
import 'package:stay_alive/features/daily_tracker/data/models/tracker_category_model.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';

abstract class DailyTrackerRemoteDataSource {
  Future<DailyLogModel?> getLogByDate(String dateKey);

  Future<DailyLogModel> initializeLog(String dateKey);

  Future<DailyLogModel> updateCategoryProgress({
    required String dateKey,
    required String categoryId,
    required int delta,
  });

  Future<DailyLogModel> resetLog(String dateKey);
}

class AppwriteDailyTrackerRemoteDataSource
    implements DailyTrackerRemoteDataSource {
  AppwriteDailyTrackerRemoteDataSource({
    required Account account,
    required Databases databases,
    required EnvConfig envConfig,
    required AppLogger logger,
  })  : _account = account,
        _databases = databases,
        _envConfig = envConfig,
        _logger = logger;

  final Account _account;
  final Databases _databases;
  final EnvConfig _envConfig;
  final AppLogger _logger;

  static const List<TrackerCategoryModel> _fallbackCategories =
      <TrackerCategoryModel>[
    TrackerCategoryModel(
      id: 'beans',
      title: 'Beans / Legumes',
      description: 'Track servings of beans and legumes',
      targetCount: 3,
      displayOrder: 1,
      iconKey: 'beans',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'berries',
      title: 'Berries',
      description: 'Track servings of berries',
      targetCount: 1,
      displayOrder: 2,
      iconKey: 'berries',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'fruits',
      title: 'Fruits',
      description: 'Track fruit servings',
      targetCount: 3,
      displayOrder: 3,
      iconKey: 'fruits',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'cruciferous_vegetables',
      title: 'Cruciferous Vegetables',
      description: 'Track cruciferous veggie servings',
      targetCount: 1,
      displayOrder: 4,
      iconKey: 'cruciferous_vegetables',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'greens',
      title: 'Greens',
      description: 'Track leafy greens servings',
      targetCount: 2,
      displayOrder: 5,
      iconKey: 'greens',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'other_vegetables',
      title: 'Other Vegetables',
      description: 'Track other vegetable servings',
      targetCount: 2,
      displayOrder: 6,
      iconKey: 'other_vegetables',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'flaxseeds',
      title: 'Flaxseeds',
      description: 'Track flaxseed servings',
      targetCount: 1,
      displayOrder: 7,
      iconKey: 'flaxseeds',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'nuts',
      title: 'Nuts',
      description: 'Track nuts servings',
      targetCount: 1,
      displayOrder: 8,
      iconKey: 'nuts',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'spices',
      title: 'Spices',
      description: 'Track turmeric/spice servings',
      targetCount: 1,
      displayOrder: 9,
      iconKey: 'spices',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'whole_grains',
      title: 'Whole Grains',
      description: 'Track whole grain servings',
      targetCount: 3,
      displayOrder: 10,
      iconKey: 'whole_grains',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'beverages',
      title: 'Beverages',
      description: 'Track healthy beverage goals',
      targetCount: 5,
      displayOrder: 11,
      iconKey: 'beverages',
      isActive: true,
    ),
    TrackerCategoryModel(
      id: 'exercise',
      title: 'Exercise',
      description: 'Track exercise sessions',
      targetCount: 1,
      displayOrder: 12,
      iconKey: 'exercise',
      isActive: true,
    ),
  ];

  @override
  Future<DailyLogModel?> getLogByDate(String dateKey) async {
    final appwrite_models.User user = await _account.get();
    return _loadLogForUser(userId: user.$id, dateKey: dateKey);
  }

  @override
  Future<DailyLogModel> initializeLog(String dateKey) async {
    final appwrite_models.User user = await _account.get();
    final DailyLogModel? existing = await _loadLogForUser(
      userId: user.$id,
      dateKey: dateKey,
    );
    if (existing != null) {
      return existing;
    }

    final List<TrackerCategoryModel> categories = await _loadCategories();
    final DateTime now = DateTime.now().toUtc();
    final List<DailyLogItemModel> items = categories
        .map(
          (TrackerCategoryModel category) => DailyLogItemModel(
            id: ID.unique(),
            category: category,
            completedCount: 0,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);

    final DailyLogModel log = _recalculateLog(
      DailyLogModel(
        id: ID.unique(),
        userId: user.$id,
        logDate: DateTime.parse('${dateKey}T00:00:00Z'),
        items: items,
        totalCompleted: 0,
        totalTarget: items.fold(
          0,
          (int sum, DailyLogItem item) => sum + item.targetCount,
        ),
        completionPercentage: 0,
        isFullyCompleted: false,
      ),
    );

    await _databases.createDocument(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogsCollectionId,
      documentId: log.id,
      data: log.toCreateData(),
      permissions: _ownerPermissions(user.$id),
    );

    for (final DailyLogItemModel item in items) {
      await _databases.createDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.dailyLogItemsCollectionId,
        documentId: item.id,
        data: item.toCreateData(logId: log.id, userId: user.$id),
        permissions: _ownerPermissions(user.$id),
      );
    }

    _logger.info(
      'Initialized Appwrite daily log',
      data: <String, Object?>{'userId': user.$id, 'dateKey': dateKey},
    );
    return log;
  }

  @override
  Future<DailyLogModel> updateCategoryProgress({
    required String dateKey,
    required String categoryId,
    required int delta,
  }) async {
    final DailyLogModel current = await initializeLog(dateKey);
    final List<DailyLogItemModel> updatedItems = current.items
        .map((DailyLogItem item) {
          final DailyLogItemModel model = DailyLogItemModel.fromEntity(item);
          if (item.categoryId != categoryId) {
            return model;
          }
          final int nextCompleted = (item.completedCount + delta).clamp(
            0,
            item.targetCount,
          );
          return model.copyWith(
            completedCount: nextCompleted,
            updatedAt: DateTime.now().toUtc(),
          );
        })
        .toList(growable: false);

    final DailyLogItemModel updatedItem = updatedItems.firstWhere(
      (DailyLogItemModel item) => item.categoryId == categoryId,
    );
    await _databases.updateDocument(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogItemsCollectionId,
      documentId: updatedItem.id,
      data: updatedItem.toUpdateData(),
    );

    return _saveRecalculatedLog(current.copyWith(items: updatedItems));
  }

  @override
  Future<DailyLogModel> resetLog(String dateKey) async {
    final DailyLogModel current = await initializeLog(dateKey);
    final List<DailyLogItemModel> resetItems = current.items
        .map(
          (DailyLogItem item) => DailyLogItemModel.fromEntity(item).copyWith(
            completedCount: 0,
            updatedAt: DateTime.now().toUtc(),
          ),
        )
        .toList(growable: false);

    for (final DailyLogItemModel item in resetItems) {
      await _databases.updateDocument(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.dailyLogItemsCollectionId,
        documentId: item.id,
        data: item.toUpdateData(),
      );
    }

    return _saveRecalculatedLog(current.copyWith(items: resetItems));
  }

  Future<DailyLogModel?> _loadLogForUser({
    required String userId,
    required String dateKey,
  }) async {
    final appwrite_models.DocumentList logs = await _databases.listDocuments(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogsCollectionId,
      queries: <String>[
        Query.equal('user_id', userId),
        Query.equal('log_date', dateKey),
        Query.limit(1),
      ],
    );
    if (logs.documents.isEmpty) {
      return null;
    }

    final appwrite_models.Document logDocument = logs.documents.first;
    final List<DailyLogItemModel> items = await _loadItemsForLog(
      logId: logDocument.data['log_id']?.toString() ?? logDocument.$id,
    );
    return _recalculateLog(
      DailyLogModel.fromDocument(document: logDocument, items: items),
    );
  }

  Future<List<DailyLogItemModel>> _loadItemsForLog({
    required String logId,
  }) async {
    final appwrite_models.DocumentList itemDocuments =
        await _databases.listDocuments(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogItemsCollectionId,
      queries: <String>[
        Query.equal('log_id', logId),
        Query.limit(100),
      ],
    );
    final List<DailyLogItemModel> items = itemDocuments.documents
        .map(DailyLogItemModel.fromDocumentWithoutCategory)
        .toList(growable: false);
    items.sort(
      (DailyLogItemModel a, DailyLogItemModel b) =>
          a.category.displayOrder.compareTo(b.category.displayOrder),
    );
    return items;
  }

  Future<List<TrackerCategoryModel>> _loadCategories() async {
    try {
      final appwrite_models.DocumentList documents =
          await _databases.listDocuments(
        databaseId: _envConfig.appwriteDatabaseId,
        collectionId: _envConfig.categoryDefinitionsCollectionId,
        queries: <String>[
          Query.equal('is_active', true),
          Query.orderAsc('display_order'),
          Query.limit(100),
        ],
      );
      if (documents.documents.isEmpty) {
        return _fallbackCategories;
      }
      return documents.documents
          .map(TrackerCategoryModel.fromDocument)
          .toList(growable: false);
    } on AppwriteException catch (exception) {
      _logger.warning(
        'Falling back to bundled category definitions',
        data: <String, Object?>{'reason': exception.message},
      );
      return _fallbackCategories;
    }
  }

  Future<DailyLogModel> _saveRecalculatedLog(DailyLogModel log) async {
    final DailyLogModel updatedLog = _recalculateLog(log);
    await _databases.updateDocument(
      databaseId: _envConfig.appwriteDatabaseId,
      collectionId: _envConfig.dailyLogsCollectionId,
      documentId: updatedLog.id,
      data: updatedLog.toUpdateData(),
    );
    return updatedLog;
  }

  DailyLogModel _recalculateLog(DailyLogModel log) {
    final int totalCompleted = log.items.fold(
      0,
      (int value, DailyLogItem item) => value + item.completedCount,
    );
    final int totalTarget = log.items.fold(
      0,
      (int value, DailyLogItem item) => value + item.targetCount,
    );
    final double completionPercentage =
        totalTarget == 0 ? 0 : (totalCompleted / totalTarget) * 100;

    return log.copyWith(
      totalCompleted: totalCompleted,
      totalTarget: totalTarget,
      completionPercentage: completionPercentage,
      isFullyCompleted: totalCompleted >= totalTarget && totalTarget > 0,
    );
  }

  List<String> _ownerPermissions(String userId) {
    return <String>[
      Permission.read(Role.user(userId)),
      Permission.update(Role.user(userId)),
      Permission.delete(Role.user(userId)),
    ];
  }
}
