import 'package:home_widget/home_widget.dart';
import 'package:stay_alive/core/env/env_config.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_progress.dart';

abstract class HomeWidgetGateway {
  Future<void> setAppGroupId(String appGroupId);

  Future<void> saveString(String key, String value);

  Future<void> saveInt(String key, int value);

  Future<void> updateWidget({
    required String androidName,
    required String iOSName,
  });
}

class HomeWidgetPluginGateway implements HomeWidgetGateway {
  const HomeWidgetPluginGateway();

  @override
  Future<void> setAppGroupId(String appGroupId) {
    return HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  Future<void> saveString(String key, String value) {
    return HomeWidget.saveWidgetData<String>(key, value);
  }

  @override
  Future<void> saveInt(String key, int value) {
    return HomeWidget.saveWidgetData<int>(key, value);
  }

  @override
  @override
  Future<void> updateWidget({
    required String androidName,
    required String iOSName,
  }) {
    return HomeWidget.updateWidget(
      androidName: androidName,
      iOSName: iOSName,
    );
  }
}

class DailyGoalWidgetService {
  DailyGoalWidgetService({
    required EnvConfig envConfig,
    required HomeWidgetGateway gateway,
  })  : _envConfig = envConfig,
        _gateway = gateway;

  static const String androidProviderName = 'DailyGoalWidgetProvider';
  static const String iOSWidgetName = 'DailyGoalWidget';

  final EnvConfig _envConfig;
  final HomeWidgetGateway _gateway;

  Future<void> initialize() async {
    await _gateway.setAppGroupId(_envConfig.widgetAppGroupId);
  }

  Future<void> updateDailyGoal({
    required DailyLog log,
    GamificationProgress? progress,
  }) async {
    await _gateway.saveInt('daily_goal_completed', log.totalCompleted);
    await _gateway.saveInt('daily_goal_target', log.totalTarget);
    await _gateway.saveInt(
      'daily_goal_percentage',
      log.completionPercentage.round().clamp(0, 100),
    );
    await _gateway.saveString('daily_goal_date', log.dateKey);
    await _gateway.saveInt(
      'daily_goal_streak',
      progress?.currentStreak ?? 0,
    );
    await _gateway.saveInt('daily_goal_level', progress?.level ?? 1);
    await _gateway.updateWidget(
      androidName: androidProviderName,
      iOSName: iOSWidgetName,
    );
  }
}
