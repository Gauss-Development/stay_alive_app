import 'package:flutter/material.dart';
import 'package:stay_alive/app.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/core/env/load_env.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnvFiles();
  await configureDependencies();
  await sl<DailyGoalWidgetService>().initialize();
  runApp(const DailyDozenApp());
}
