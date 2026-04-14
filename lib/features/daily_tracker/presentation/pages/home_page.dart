import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/daily_tracker/presentation/widgets/category_progress_tile.dart';
import 'package:stay_alive/features/daily_tracker/presentation/widgets/daily_progress_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Dozen'),
      ),
      body: SafeArea(
        child: BlocBuilder<DailyTrackerCubit, DailyTrackerState>(
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

            return RefreshIndicator(
              onRefresh: () => context.read<DailyTrackerCubit>().loadToday(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  DailyProgressCard(log: log),
                  const SizedBox(height: 16),
                  Text(
                    'Today\'s Checklist',
                    style: Theme.of(context).textTheme.titleMedium,
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
                    onPressed: () => context.read<DailyTrackerCubit>().resetToday(),
                    child: const Text('Reset Today'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
