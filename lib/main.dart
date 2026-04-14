import 'package:flutter/material.dart';
import 'package:stay_alive/app.dart';
import 'package:stay_alive/core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const DailyDozenApp());
}
