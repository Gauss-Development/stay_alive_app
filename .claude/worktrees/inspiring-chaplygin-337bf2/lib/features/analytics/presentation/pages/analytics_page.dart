import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Analytics',
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (BuildContext context, AnalyticsState state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnalyticsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(state.message),
              ),
            );
          }

          if (state is AnalyticsTracked) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Tracked event: ${state.event.name}'),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No analytics events tracked in this session.'),
          );
        },
      ),
    );
  }
}
