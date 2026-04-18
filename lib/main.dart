import 'package:flutter/material.dart';
import 'package:stay_alive/app.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/core/env/load_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnvFiles();
  await configureDependencies();
  runApp(const DailyDozenApp());
}
