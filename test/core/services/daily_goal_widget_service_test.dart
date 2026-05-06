import 'package:flutter_test/flutter_test.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';

class _RecordingHomeWidgetGateway implements HomeWidgetGateway {
  final Map<String, Object> values = <String, Object>{};
  String? appGroupId;
  int updateCalls = 0;

  @override
  Future<void> setAppGroupId(String appGroupId) async {
    this.appGroupId = appGroupId;
  }

  @override
  Future<void> saveString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> saveInt(String key, int value) async {
    values[key] = value;
  }

  @override
  Future<void> updateWidget({
    required String androidName,
    required String iOSName,
  }) async {
    values['androidName'] = androidName;
    values['iOSName'] = iOSName;
    updateCalls += 1;
  }
}

void main() {
  test('initializes the configured iOS app group', () async {
    final _RecordingHomeWidgetGateway gateway = _RecordingHomeWidgetGateway();
    final DailyGoalWidgetService service = DailyGoalWidgetService(
      envConfig: _envConfig,
      gateway: gateway,
    );

    await service.initialize();

    expect(gateway.appGroupId, 'group.test.stayAlive');
  });

  test('saves daily goal values and triggers a widget update', () async {
    final _RecordingHomeWidgetGateway gateway = _RecordingHomeWidgetGateway();
    final DailyGoalWidgetService service = DailyGoalWidgetService(
      envConfig: _envConfig,
      gateway: gateway,
    );

    await service.updateDailyGoal(
      log: DailyLog(
        id: 'log_1',
        userId: 'user_1',
        logDate: DateTime.utc(2026, 5, 6),
        items: const <Never>[],
        totalCompleted: 6,
        totalTarget: 24,
        completionPercentage: 25,
        isFullyCompleted: false,
      ),
    );

    expect(gateway.values['daily_goal_completed'], 6);
    expect(gateway.values['daily_goal_target'], 24);
    expect(gateway.values['daily_goal_percentage'], 25);
    expect(gateway.values['daily_goal_date'], '2026-05-06');
    expect(gateway.values['androidName'], 'DailyGoalWidgetProvider');
    expect(gateway.values['iOSName'], 'DailyGoalWidget');
    expect(gateway.updateCalls, 1);
  });
}

const EnvConfig _envConfig = EnvConfig(
  appwriteEndpoint: '',
  appwriteProjectId: '',
  appwriteProjectName: '',
  appwriteDatabaseId: '',
  usersCollectionId: '',
  categoryDefinitionsCollectionId: '',
  dailyLogsCollectionId: '',
  dailyLogItemsCollectionId: '',
  subscriptionsCollectionId: '',
  analyticsEventsCollectionId: '',
  educationalContentCollectionId: '',
  gamificationProfilesCollectionId: '',
  gamificationEventsCollectionId: '',
  widgetAppGroupId: 'group.test.stayAlive',
  revenueCatAndroidApiKey: '',
  revenueCatIosApiKey: '',
  revenueCatEntitlementId: 'premium',
  revenueCatOfferingId: 'default',
  avatarsBucketId: '',
  userUploadsBucketId: '',
  contentAssetsBucketId: '',
  allowSelfSigned: false,
);
