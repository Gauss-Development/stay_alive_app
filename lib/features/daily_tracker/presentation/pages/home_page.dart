import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/core/services/daily_goal_widget_service.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/animations/staggered_list.dart';
import 'package:stay_alive/core/widgets/app_chip.dart';
import 'package:stay_alive/core/widgets/app_section_header.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/daily_tracker/presentation/widgets/category_progress_tile.dart';
import 'package:stay_alive/features/daily_tracker/presentation/widgets/daily_progress_card.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/daily_challenge_card.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

enum _CategoryFilter { all, remaining, done }

class HomePage extends StatefulWidget {
  const HomePage({this.dailyGoalWidgetService, super.key});

  final DailyGoalWidgetService? dailyGoalWidgetService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _CategoryFilter _filter = _CategoryFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bool isPremium = context
            .read<SubscriptionCubit>()
            .state
            .isPremiumActive;
        context.read<DailyTrackerCubit>().loadToday();
        context.read<GamificationCubit>().load(isPremium: isPremium);
        if (context.read<UserProfileCubit>().state is UserProfileInitial) {
          context.read<UserProfileCubit>().load();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<DailyTrackerCubit, DailyTrackerState>(
          listenWhen: (DailyTrackerState previous, DailyTrackerState current) =>
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
              final bool isPremium = context
                  .read<SubscriptionCubit>()
                  .state
                  .isPremiumActive;
              unawaited(
                context.read<GamificationCubit>().refreshToday(
                  todayLog: state.log!,
                  isPremium: isPremium,
                ),
              );
            }
          },
          builder: (BuildContext context, DailyTrackerState state) {
            if (state.status == DailyTrackerStatus.initial ||
                state.status == DailyTrackerStatus.loading) {
              return const AppLoadingState(message: 'Готовим твой день...');
            }

            if (state.status == DailyTrackerStatus.error) {
              return AppErrorState(
                onRetry: () => context.read<DailyTrackerCubit>().loadToday(),
              );
            }

            final DailyLog? log = state.log;
            if (log == null) {
              return const SizedBox.shrink();
            }

            return BlocListener<GamificationCubit, GamificationState>(
              listenWhen:
                  (GamificationState previous, GamificationState current) =>
                      current is GamificationLoaded &&
                      (previous is! GamificationLoaded ||
                          previous.overview.profile !=
                              current.overview.profile),
              listener:
                  (BuildContext context, GamificationState gamificationState) {
                    if (gamificationState is! GamificationLoaded) {
                      return;
                    }
                    unawaited(
                      (widget.dailyGoalWidgetService ??
                              sl<DailyGoalWidgetService>())
                          .updateDailyGoal(
                            log: log,
                            profile: gamificationState.overview.profile,
                          ),
                    );
                  },
              child: RefreshIndicator(
                color: AppColors.green,
                onRefresh: () async {
                  await context.read<DailyTrackerCubit>().loadToday();
                  if (!context.mounted) {
                    return;
                  }
                  final bool isPremium = context
                      .read<SubscriptionCubit>()
                      .state
                      .isPremiumActive;
                  await context.read<GamificationCubit>().refresh(
                    isPremium: isPremium,
                  );
                },
                child: _buildContent(context, log),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyLog log) {
    final List<DailyLogItem> items = switch (_filter) {
      _CategoryFilter.all => log.items,
      _CategoryFilter.remaining =>
        log.items.where((DailyLogItem i) => !i.isCompleted).toList(),
      _CategoryFilter.done =>
        log.items.where((DailyLogItem i) => i.isCompleted).toList(),
    };
    final int eaten = log.items.where((DailyLogItem i) => i.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xl,
      ),
      children: <Widget>[
        const FadeSlideIn(child: _HomeHeader()),
        const SizedBox(height: AppSpacing.lg),
        ScalePop(
          delay: const Duration(milliseconds: 80),
          fromScale: 0.96,
          child: BlocBuilder<GamificationCubit, GamificationState>(
            builder: (BuildContext context, GamificationState state) {
              final bool loaded = state is GamificationLoaded;
              return DailyProgressCard(
                log: log,
                level: loaded
                    ? state.overview.profile.currentLevel.level
                    : null,
                levelTitle: loaded
                    ? state.overview.profile.currentLevel.title
                    : null,
                streak: loaded ? state.overview.profile.currentStreak : null,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: BlocBuilder<GamificationCubit, GamificationState>(
            buildWhen:
                (GamificationState previous, GamificationState current) =>
                    previous.runtimeType != current.runtimeType ||
                    (current is GamificationLoaded &&
                        previous is GamificationLoaded &&
                        previous.overview.dailyChallenge !=
                            current.overview.dailyChallenge),
            builder: (BuildContext context, GamificationState state) {
              if (state is GamificationLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: DailyChallengeCard(
                    challenge: state.overview.dailyChallenge,
                    isPremium: state.overview.isPremium,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: _buildFilters(),
        ),
        const SizedBox(height: AppSpacing.xl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 280),
          child: AppSectionHeader(
            title: 'Съедено сегодня',
            trailing: Text(
              '$eaten/${log.items.length}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppEmptyState(
              title: 'Пока пусто',
              message: 'Добавь первый полезный продукт и получи очки',
            ),
          )
        else
          for (final (int index, DailyLogItem item) in items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StaggeredFadeSlide(
                index: index,
                baseDelay: const Duration(milliseconds: 320),
                child: CategoryProgressTile(
                  item: item,
                  tintIndex: log.items.indexOf(item),
                  onIncrement: () => context
                      .read<DailyTrackerCubit>()
                      .increment(item.categoryId),
                  onDecrement: () => context
                      .read<DailyTrackerCubit>()
                      .decrement(item.categoryId),
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: () => context.read<DailyTrackerCubit>().resetToday(),
            child: Text(
              'Сбросить день',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          AppChip(
            label: 'Все',
            selected: _filter == _CategoryFilter.all,
            onTap: () => setState(() => _filter = _CategoryFilter.all),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Осталось',
            selected: _filter == _CategoryFilter.remaining,
            onTap: () => setState(() => _filter = _CategoryFilter.remaining),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppChip(
            label: 'Готово',
            selected: _filter == _CategoryFilter.done,
            onTap: () => setState(() => _filter = _CategoryFilter.done),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (BuildContext context, UserProfileState state) {
              final String? name = state is UserProfileLoaded
                  ? state.profile.displayName
                  : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name == null || name.isEmpty
                        ? 'Привет! 🌱'
                        : 'Привет, $name 🌱',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Что съедим полезного?',
                    style: AppTextStyles.headlineMedium,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.mutedGreen,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
