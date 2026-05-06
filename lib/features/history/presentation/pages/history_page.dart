import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_cubit.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_state.dart';
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
      appBar: AppBar(title: const Text('History')),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listenWhen: (SubscriptionState previous, SubscriptionState current) =>
            previous.info != current.info && current.isPremiumActive,
        listener: (BuildContext context, SubscriptionState state) {
          context.read<HistoryCubit>().load();
        },
        builder: (BuildContext context, SubscriptionState subscriptionState) {
          if (subscriptionState.status == SubscriptionStatus.initial ||
              subscriptionState.status == SubscriptionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!subscriptionState.isPremiumActive) {
            return _HistoryPaywallPrompt(
              message: subscriptionState.errorMessage,
            );
          }

          return _HistoryBody();
        },
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
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
                child: Text(state.message),
              ),
            );
          }

          if (state is! HistoryLoaded) {
            return const SizedBox.shrink();
          }

          final summary = state.summary;
          if (summary.totalDays == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No history data available yet.'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const ListTile(
                  leading: Icon(Icons.lock_open),
                  title: Text('Premium statistics unlocked'),
                  subtitle: Text(
                    'Your long-term healthy eating insights are active.',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text(summary.periodLabel),
                  subtitle: Text(
                    '${summary.completedDays}/${summary.totalDays} days completed',
                  ),
                  trailing: Text(
                    '${summary.averageCompletionPercentage.toStringAsFixed(1)}%',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Current streak'),
                  trailing: Text('${summary.currentStreak} days'),
                ),
              ),
            ],
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
          'Daily fruit and vegetable tracking stays free. Upgrade to see full trends, streaks, weekly averages, and monthly progress insights.',
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
