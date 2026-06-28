import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/daily_tracker/presentation/widgets/category_progress_tile.dart';
import 'package:stay_alive/features/daily_tracker/presentation/widgets/daily_progress_card.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/gamification_celebration_host.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/gamification_progress_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    this.dailyGoalWidgetService,
    super.key,
  });

  final DailyGoalWidgetService? dailyGoalWidgetService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DailyTrackerCubit>().loadToday();
        context.read<GamificationCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GamificationCelebrationHost(
      child: Scaffold(
        appBar: AppBar(title: const Text('Daily Dozen')),
        body: SafeArea(
          child: BlocConsumer<DailyTrackerCubit, DailyTrackerState>(
            listenWhen: (
              DailyTrackerState previous,
              DailyTrackerState current,
            ) =>
                previous.errorMessage != current.errorMessage ||
                previous.log != current.log,
            listener: (BuildContext context, DailyTrackerState state) {
              final String? errorMessage = state.errorMessage;
              if (errorMessage != null &&
                  state.status == DailyTrackerStatus.loaded) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorMessage)));
              }

              if (state.status == DailyTrackerStatus.loaded &&
                  state.log != null) {
                unawaited(context.read<GamificationCubit>().refresh());
              }
            },
            builder: (BuildContext context, DailyTrackerState state) {
              if (state.status == DailyTrackerStatus.initial ||
                  state.status == DailyTrackerStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == DailyTrackerStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.errorMessage ?? 'Could not load tracker.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final log = state.log;
              if (log == null) {
                return const SizedBox.shrink();
              }

              return BlocListener<GamificationCubit, GamificationState>(
                listenWhen: (
                  GamificationState previous,
                  GamificationState current,
                ) =>
                    current is GamificationLoaded &&
                    (previous is! GamificationLoaded ||
                        previous.profile != current.profile),
                listener: (
                  BuildContext context,
                  GamificationState gamificationState,
                ) {
                  if (gamificationState is! GamificationLoaded) {
                    return;
                  }
                  unawaited(
                    (widget.dailyGoalWidgetService ??
                            sl<DailyGoalWidgetService>())
                        .updateDailyGoal(
                      log: log,
                      profile: gamificationState.profile,
                    ),
                  );
                },
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<DailyTrackerCubit>().loadToday();
                    if (!context.mounted) {
                      return;
                    }
                    await context.read<GamificationCubit>().refresh();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      DailyProgressCard(log: log),
                      const SizedBox(height: 16),
                      BlocBuilder<GamificationCubit, GamificationState>(
                        builder: (
                          BuildContext context,
                          GamificationState gamificationState,
                        ) {
                          if (gamificationState is GamificationLoaded) {
                            return GamificationProgressCard(
                              profile: gamificationState.profile,
                            );
                          }

                          if (gamificationState is GamificationError) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(gamificationState.message),
                              ),
                            );
                          }

                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Loading your progress rewards...'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'What did you eat today?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to log a serving in each Daily Dozen category.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...log.items.map(
                        (item) => CategoryProgressTile(
                          item: item,
                          onIncrement: () => context
                              .read<DailyTrackerCubit>()
                              .increment(item.categoryId),
                          onDecrement: () => context
                              .read<DailyTrackerCubit>()
                              .decrement(item.categoryId),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () =>
                            context.read<DailyTrackerCubit>().resetToday(),
                        child: const Text('Reset Today'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
