import 'package:equatable/equatable.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';

class ReconcileGamificationParams extends Equatable {
  const ReconcileGamificationParams({required this.isPremium});

  final bool isPremium;

  @override
  List<Object?> get props => <Object?>[isPremium];
}

class ReconcileGamificationTodayParams extends Equatable {
  const ReconcileGamificationTodayParams({
    required this.todayLog,
    required this.isPremium,
  });

  final DailyLog todayLog;
  final bool isPremium;

  @override
  List<Object?> get props => <Object?>[todayLog, isPremium];
}
