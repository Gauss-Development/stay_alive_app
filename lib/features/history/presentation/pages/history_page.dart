import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_cubit.dart';
import 'package:stay_alive/features/history/presentation/cubit/history_state.dart';

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
        context.read<HistoryCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
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
      ),
    );
  }
}
