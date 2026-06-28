import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
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
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listenWhen: (SubscriptionState previous, SubscriptionState current) =>
            previous.info != current.info && current.isPremiumActive,
        listener: (BuildContext context, SubscriptionState state) {
          context.read<HistoryCubit>().load();
        },
        builder: (BuildContext context, SubscriptionState subscriptionState) {
          if (subscriptionState.status == SubscriptionViewStatus.initial ||
              subscriptionState.status == SubscriptionViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!subscriptionState.isPremiumActive) {
            return _HistoryPaywallPrompt(
              message: subscriptionState.errorMessage,
            );
          }

          return const _HistoryBody();
        },
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
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HistoryError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<HistoryCubit>().load(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! HistoryLoaded) {
          return const SizedBox.shrink();
        }

        final summary = state.summary;
        final weeklyPoints = summary.pointsForLastDays(7);
        final monthlyPoints = summary.dailyPoints;

        return RefreshIndicator(
          onRefresh: () => context.read<HistoryCubit>().load(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                summary.periodLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track how consistently you complete the Daily Dozen over time.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              HistoryStatsGrid(summary: summary),
              const SizedBox(height: 16),
              CompletionTrendChart(
                points: weeklyPoints,
                title: 'Last 7 days',
              ),
              const SizedBox(height: 16),
              CompletionTrendChart(
                points: monthlyPoints,
                title: 'Last 30 days',
              ),
              const SizedBox(height: 16),
              DailyServingsChart(points: monthlyPoints),
              const SizedBox(height: 16),
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
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Icon(
          Icons.insights,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Full statistics are Premium',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Daily fruit and vegetable tracking stays free. Upgrade to see completion trends, serving charts, streaks, and monthly progress insights.',
          textAlign: TextAlign.center,
        ),
        if (message != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.premium),
          icon: const Icon(Icons.workspace_premium),
          label: const Text('View Premium Plans'),
        ),
        TextButton(
          onPressed: () => context.read<SubscriptionCubit>().load(),
          child: const Text('I already subscribed — refresh'),
        ),
      ],
    );
  }
}
