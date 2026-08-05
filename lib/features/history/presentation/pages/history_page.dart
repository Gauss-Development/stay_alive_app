import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/green_sprout_rive.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/coach/domain/services/coach_context_builder.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/coach/presentation/widgets/weekly_insight_section.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_cubit.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_state.dart';
import 'package:stay_alive/features/history/presentation/widgets/completion_trend_chart.dart';
import 'package:stay_alive/features/history/presentation/widgets/daily_completion_heatmap.dart';
import 'package:stay_alive/features/history/presentation/widgets/daily_servings_chart.dart';
import 'package:stay_alive/features/history/presentation/widgets/history_stats_grid.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SubscriptionCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listenWhen: (SubscriptionState previous, SubscriptionState current) =>
              previous.info != current.info && current.isPremiumActive,
          listener: (BuildContext context, SubscriptionState state) {
            context.read<HistoryCubit>().load();
          },
          builder: (BuildContext context, SubscriptionState subscriptionState) {
            if (subscriptionState.status == SubscriptionViewStatus.initial ||
                subscriptionState.status == SubscriptionViewStatus.loading) {
              return const AppLoadingState();
            }

            if (!subscriptionState.isPremiumActive) {
              return _HistoryPaywallPrompt(
                message: subscriptionState.errorMessage,
              );
            }

            return const _HistoryBody();
          },
        ),
      ),
    );
  }
}

class _HistoryBody extends StatefulWidget {
  const _HistoryBody();

  @override
  State<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<_HistoryBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoryCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (BuildContext context, HistoryState state) {
        if (state is HistoryInitial || state is HistoryLoading) {
          return const AppLoadingState(message: 'Считаем твой прогресс...');
        }

        if (state is HistoryError) {
          return AppErrorState(
            onRetry: () => context.read<HistoryCubit>().load(),
          );
        }

        if (state is! HistoryLoaded) {
          return const SizedBox.shrink();
        }

        final summary = state.summary;
        final weeklyPoints = summary.pointsForLastDays(7);
        final monthlyPoints = summary.dailyPoints;

        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: () => context.read<HistoryCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            children: <Widget>[
              FadeSlideIn(
                child: Text(
                  summary.periodLabel,
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'Смотри, как растёт твоя полезная привычка.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: HistoryStatsGrid(summary: summary),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: WeeklyInsightSection(
                  onRequestInsights: () {
                    final bool isPremium = context
                        .read<SubscriptionCubit>()
                        .state
                        .isPremiumActive;
                    final gState = context.read<GamificationCubit>().state;
                    context.read<CoachCubit>().loadWeeklyInsights(
                          context: CoachContextBuilder.build(
                            overview: gState is GamificationLoaded
                                ? gState.overview
                                : null,
                            weekSummary: summary.periodLabel,
                          ),
                          isPremium: isPremium,
                        );
                    context.read<AnalyticsCubit>().track(
                          eventName: 'coach_weekly_insight',
                          screenName: 'history',
                        );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CompletionTrendChart(
                points: weeklyPoints,
                title: 'Последние 7 дней',
              ),
              const SizedBox(height: AppSpacing.lg),
              CompletionTrendChart(
                points: monthlyPoints,
                title: 'Последние 30 дней',
              ),
              const SizedBox(height: AppSpacing.lg),
              DailyServingsChart(points: monthlyPoints),
              const SizedBox(height: AppSpacing.lg),
              DailyCompletionHeatmap(points: monthlyPoints),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryPaywallPrompt extends StatelessWidget {
  const _HistoryPaywallPrompt({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: <Widget>[
        const SizedBox(height: AppSpacing.xl),
        const Center(child: GreenSproutRiveEmblem(size: 120)),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Полная статистика — в Premium',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Отмечать полезные продукты можно бесплатно. С Premium ты увидишь '
          'тренды, серии, графики порций и прогресс за месяц.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        if (message != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          text: 'Посмотреть Premium',
          onPressed: () => context.go(AppRoutes.premium),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => context.read<SubscriptionCubit>().load(),
          child: const Text('Я уже подписан — обновить'),
        ),
      ],
    );
  }
}
